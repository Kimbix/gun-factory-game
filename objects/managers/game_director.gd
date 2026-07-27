class_name GameDirector
extends WorldEnvironment

@export var player_character_scene: PackedScene
@export var enemy_waves: EnemyWaves
@export var enemy_events: EnemyEvents
@export var enemy_cap := 50
@export_category("Spawn Specifications")
@export var spawn_interval := 10.0
@export var spawn_per_wave_percent := .05
@export var spawn_distance_min := 250.0
@export var spawn_distance_max := 400.0

const HP_SCALE := 0.1
const SPEED_SCALE := 0.05
const DAMAGE_SCALE := 0.05
const CAP_PER_DIFFICULTY := 10
const RATE_SCALE := 0.02

var elapsed_time: float
var enemies: Array[BaseEnemy] = []
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
	_spawn_enemies()


func _process(delta: float) -> void:
	elapsed_time += delta

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
	var effective_cap := ceili(enemy_cap + diff * CAP_PER_DIFFICULTY)
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


func _on_enemy_killed(which: BaseEnemy) -> void:
	enemies.erase(which)


func _handle_event(event: EnemyEvent) -> void:
	_spawn_boss(event)


func _spawn_boss(event: EnemyEvent) -> void:
	var diff := _get_difficulty()
	print("GameDirector: spawning boss")
	for i in event.count:
		var instance: BaseEnemy = event.enemy_info.scene.instantiate()
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
