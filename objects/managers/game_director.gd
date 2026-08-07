class_name GameDirector
extends WorldEnvironment

const HP_SCALE := 1.0
const SPEED_SCALE := 0.5
const DAMAGE_SCALE := 0.5
const CAP_PER_DIFFICULTY := 50
const RATE_SCALE := 0.2
## Will change per stage in the future.
const WIN_TIME := 30.0 * 60.0

@export var player_character_scene: PackedScene
@export var enemy_waves: EnemyWaves
@export var enemy_events: EnemyEvents
@export var base_enemy_cap := 50
@export var base_loot_box_cap := 5
@export_category("Spawn Specifications")
@export var spawn_interval := 10.0
@export var loot_box_spawn_interval := 10.0
@export var spawn_per_wave_percent := .05
@export var spawn_distance_min := 250.0
@export var spawn_distance_max := 400.0
@export var reaper_scene: PackedScene
@export var loot_box_scene: PackedScene

var elapsed_time: float
var win_triggered: bool
var enemies: Array[BaseEnemy] = []
var loot_boxes: Array[LootBox] = []
var active_wave: EnemyWave
var wave_index: int
var player_instance: SimpleCharacter


func _ready() -> void:
	_spawn_player()
	elapsed_time = 0.0
	wave_index = 0
	active_wave = enemy_waves.get_first()

	if enemy_events != null:
		print("GameDirector: enemy_events found, ", enemy_events.events.size(), " event(s)")
		enemy_events.setup()
	else:
		print("GameDirector: enemy_events is null")

	var timer := Timer.new()
	timer.timeout.connect(_spawn_enemies)
	timer.wait_time = spawn_interval
	timer.autostart = true
	add_child(timer)

	var loot_box_timer := Timer.new()
	loot_box_timer.timeout.connect(_spawn_loot_boxes)
	loot_box_timer.wait_time = loot_box_spawn_interval
	loot_box_timer.autostart = true
	add_child(loot_box_timer)

	var damage_pool := DamageNumberPool.new()
	add_child(damage_pool)

	_spawn_enemies()
	_spawn_loot_boxes()


func _process(delta: float) -> void:
	if not win_triggered and is_instance_valid(player_instance) and player_instance.health > 0:
		elapsed_time += delta

	if not win_triggered and elapsed_time >= WIN_TIME:
		_trigger_win_condition()

	if active_wave != null and elapsed_time >= active_wave.end_time_minutes * 60.0:
		wave_index += 1
		active_wave = enemy_waves.get_wave(wave_index)

	if enemy_events != null:
		var event := enemy_events.get_next_unfired(elapsed_time)
		while event != null:
			print("GameDirector: event fired at ", elapsed_time, "s")
			_handle_event(event)
			event = enemy_events.get_next_unfired(elapsed_time)


func _spawn_player(spawn_pos: Vector2 = Vector2.ZERO) -> void:
	player_instance = player_character_scene.instantiate()
	player_instance.position = spawn_pos
	add_child(player_instance)


func _get_difficulty() -> float:
	if not is_instance_valid(player_instance):
		return 0.0
	return player_instance.player_stats.stats[&"difficulty"].value


func _apply_difficulty(instance: BaseEnemy, diff: float) -> void:
	instance.health = maxi(1, ceili(instance.health * (1.0 + diff * HP_SCALE)))
	instance.speed *= 1.0 + diff * SPEED_SCALE
	instance.damage_multiplier = 1.0 + diff * DAMAGE_SCALE


func _spawn_enemies() -> void:
	var diff := _get_difficulty()
	var effective_cap := ceili(base_enemy_cap + diff * CAP_PER_DIFFICULTY)
	var effective_rate := spawn_per_wave_percent * (1.0 + diff * RATE_SCALE)

	if active_wave == null or enemies.size() >= effective_cap:
		return

	var missing: int = effective_cap - enemies.size()
	var to_spawn := ceili(missing * effective_rate)
	for i: Variant in to_spawn:
		if enemies.size() >= effective_cap:
			return

		var info: EnemyInfo = active_wave.enemies.pick_random()
		var instance: BaseEnemy = info.scene.instantiate()
		instance.name = _enemy_name(info.scene, enemies.size())
		instance.player = player_instance
		instance.game_world = self
		instance.position = (
				player_instance.position
				+ ((Vector2.RIGHT * randf_range(spawn_distance_min, spawn_distance_max))
						.rotated(randf() * TAU))
		)

		var xp_range := randf_range(1.0 - info.variance, 1.0 + info.variance)
		instance.xp_amount = ceili(info.base_xp * xp_range)
		_apply_difficulty(instance, diff)

		add_child(instance)
		enemies.append(instance)
		instance.tree_exited.connect(_on_enemy_killed.bind(instance))


## Builds a debug-friendly name for a spawned enemy using its scene's file name
## and its position (index) in the [member enemies] array.
func _enemy_name(scene: PackedScene, spot_taken: int) -> String:
	return "%s_%d" % [scene.resource_path.get_file().get_basename(), spot_taken]


func _on_enemy_killed(which: BaseEnemy) -> void:
	enemies.erase(which)


func _spawn_loot_boxes() -> void:
	if loot_box_scene == null:
		return

	var diff := _get_difficulty()
	var effective_rate := spawn_per_wave_percent * (1.0 + diff * RATE_SCALE)
	var missing: int = base_loot_box_cap - loot_boxes.size()
	var to_spawn := ceili(maxf(missing, 1.0) * effective_rate)
	for i: int in to_spawn:
		if loot_boxes.size() >= base_loot_box_cap and not _despawn_oldest_loot_box():
			return

		var instance: LootBox = loot_box_scene.instantiate()
		instance.position = (
				player_instance.position
				+ ((Vector2.RIGHT * randf_range(spawn_distance_min, spawn_distance_max))
						.rotated(randf() * TAU))
		)

		add_child(instance)
		loot_boxes.append(instance)
		instance.tree_exited.connect(_on_loot_box_removed.bind(instance))


## Despawns the oldest off-screen loot box to make room for a new one.
## Returns `true` if a box was despawned, `false` if every box is on screen.
func _despawn_oldest_loot_box() -> bool:
	for index: int in loot_boxes.size():
		var candidate: LootBox = loot_boxes[index]
		if not is_instance_valid(candidate):
			loot_boxes.remove_at(index)
			return true
		if not _is_on_screen(candidate):
			loot_boxes.remove_at(index)
			candidate.queue_free()
			return true
	return false


func _is_on_screen(loot_box: LootBox) -> bool:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return true
	var to_world := camera.get_canvas_transform().affine_inverse()
	var view_size := get_viewport().get_visible_rect().size
	var world_top_left := to_world * Vector2.ZERO
	var world_bottom_right := to_world * view_size
	var world_rect := Rect2(world_top_left, world_bottom_right - world_top_left)
	return world_rect.has_point(loot_box.global_position)


func _on_loot_box_removed(which: LootBox) -> void:
	loot_boxes.erase(which)


func _handle_event(event: EnemyEvent) -> void:
	_spawn_boss(event)


func _spawn_boss(event: EnemyEvent) -> void:
	var diff := _get_difficulty()
	print("GameDirector: spawning boss")
	for i in event.count:
		var instance: BaseEnemy = event.enemy_info.scene.instantiate()
		instance.name = _enemy_name(event.enemy_info.scene, enemies.size())
		instance.enemy_type = BaseEnemy.EnemyType.BOSS
		instance.player = player_instance
		instance.game_world = self
		instance.position = (
				player_instance.position
				+ ((Vector2.RIGHT * randf_range(spawn_distance_min, spawn_distance_max))
						.rotated(randf() * TAU))
		)

		var variance := event.enemy_info.variance
		var xp_range := randf_range(1.0 - variance, 1.0 + variance)
		instance.xp_amount = ceili(event.enemy_info.base_xp * xp_range)
		_apply_difficulty(instance, diff)

		add_child(instance)
		enemies.append(instance)
		instance.tree_exited.connect(_on_enemy_killed.bind(instance))


func _trigger_win_condition() -> void:
	win_triggered = true
	print("GameDirector: win condition triggered at ", elapsed_time, "s")
	for enemy: BaseEnemy in enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.die_silently()
	_spawn_reaper()


func _spawn_reaper() -> void:
	var instance: BaseEnemy = reaper_scene.instantiate()
	instance.name = _enemy_name(reaper_scene, enemies.size())
	instance.player = player_instance
	instance.game_world = self
	instance.position = (
			player_instance.position
			+ ((Vector2.RIGHT * randf_range(spawn_distance_min, spawn_distance_max))
					.rotated(randf() * TAU))
	)

	add_child(instance)
	enemies.append(instance)
	instance.tree_exited.connect(_on_enemy_killed.bind(instance))
