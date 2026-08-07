class_name SimpleCharacter
extends CharacterBody2D

signal leveled_up(level: int)
signal damaged(current_health: float)
signal died

static var _actions_ready := false

@export var starting_grid_data: PlayerGridData

var current_target: Node2D
var player_grid: PlayerGrid
var building_inventory: PlayerBuildingInventory
var level_system: LevelSystem
var player_stats: PlayerStats
var health: float
var _dead: bool
var _tick_timer: Timer
var _regen_timer: Timer


static func _setup_input_actions() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

	var key_events := {
		"move_left": [KEY_A],
		"move_right": [KEY_D],
		"move_up": [KEY_W],
		"move_down": [KEY_S],
	}

	for action in key_events:
		for keycode in key_events[action]:
			var event := InputEventKey.new()
			event.keycode = keycode
			InputMap.action_add_event(action, event)


func _ready() -> void:
	if not _actions_ready:
		_setup_input_actions()
		_actions_ready = true

	building_inventory = PlayerBuildingInventory.new()
	level_system = LevelSystem.new()
	add_child(level_system)
	level_system.leveled_up.connect(_on_level_up)
	level_system.xp_changed.connect(_on_level_xp_changed)
	level_system.gold_changed.connect(_on_level_gold_changed)

	player_stats = PlayerStats.new(PlayerStatsData.new())
	health = player_stats.stats[&"max_health"].value

	add_to_group("player")

	player_grid = PlayerGrid.new()
	player_grid.output_item.connect(_shoot)
	player_grid.building_placed.connect(_on_building_placed)
	player_grid.building_removed.connect(_on_building_removed)

	_tick_timer = Timer.new()
	_tick_timer.timeout.connect(player_grid.tick)
	_tick_timer.wait_time = player_stats.stats[&"tick_speed"].value
	add_child(_tick_timer)

	_regen_timer = Timer.new()
	_regen_timer.timeout.connect(_apply_regen)
	_regen_timer.wait_time = 1.0
	add_child(_regen_timer)

	if starting_grid_data != null:
		player_grid.from_data(starting_grid_data)
	else:
		player_grid.initialize_empty()

	_tick_timer.start()
	_regen_timer.start()

	sync_stats()

	$CollectionArea.area_entered.connect(_on_collection_area_entered)
	$MagnetAttractionArea.area_entered.connect(_on_magnet_attraction_area_entered)
	$DespawnProximity.area_exited.connect(_on_despawn_proximity_area_exited)
	$BossProximity.area_exited.connect(_on_boss_proximity_area_exited)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_stats.stats[&"move_speed"].value
	move_and_slide()


func sync_stats() -> void:
	var tick_spd: float = player_stats.stats[&"tick_speed"].value
	_tick_timer.wait_time = maxf(tick_spd, 0.01)

	$CollectionArea/CollisionShape2D.shape.radius = player_stats.stats[&"pickup_range"].value

	var max_hp: float = player_stats.stats[&"max_health"].value
	if health > max_hp:
		health = max_hp

	var regen: float = player_stats.stats[&"health_regen"].value
	if regen > 0:
		_regen_timer.wait_time = 1.0
		_regen_timer.start()
	else:
		_regen_timer.stop()


func find_target() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := INF
	for node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Node2D
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest


func take_damage(amount: float, enemy_type: StringName = &"") -> void:
	if _dead:
		return
	var reduction: float = player_stats.stats[&"armor"].value
	var final_damage := maxf(amount * (1.0 - reduction), 1.0)
	health -= final_damage
	SignalBus.damage_taken.emit(ceili(final_damage), enemy_type)
	if health <= 0:
		health = 0
		_dead = true
		died.emit()
		_on_player_died()
	damaged.emit(health)


func _on_collection_area_entered(area: Area2D) -> void:
	var crystal := area as ExperienceCrystal
	if crystal == null:
		return
	if not crystal.collected.is_connected(_on_crystal_collected):
		crystal.collected.connect(_on_crystal_collected.bind(crystal), CONNECT_ONE_SHOT)
	crystal.start_follow(self)


func _on_crystal_collected(crystal: ExperienceCrystal) -> void:
	SignalBus.crystal_collected.emit(crystal.xp_value)
	var xp_mult: float = player_stats.stats[&"xp_gain"].value
	var gold_mult: float = player_stats.stats[&"gold_gain"].value
	level_system.add_xp(crystal.xp_value, xp_mult, gold_mult)


func _on_magnet_attraction_area_entered(area: Area2D) -> void:
	var magnet := area as MagnetItem
	if magnet == null:
		return
	magnet.start_follow(self)


func _on_despawn_proximity_area_exited(area: Area2D) -> void:
	var enemy := area if area is BaseEnemy else null
	if enemy == null or not is_instance_valid(enemy):
		return
	if enemy.enemy_type != BaseEnemy.EnemyType.REGULAR:
		return
	enemy.queue_free()


func _on_boss_proximity_area_exited(area: Area2D) -> void:
	var enemy := area if area is BaseEnemy else null
	if enemy == null or not is_instance_valid(enemy):
		return
	if enemy.enemy_type != BaseEnemy.EnemyType.BOSS:
		return
	var angle := randf() * TAU
	var radius := randf_range(enemy.spawn_distance_min, enemy.spawn_distance_max)
	enemy.global_position = global_position + Vector2.RIGHT.rotated(angle) * radius


func _on_level_up(new_level: int) -> void:
	print("Level ", new_level, "!")
	leveled_up.emit(new_level)


func _on_level_xp_changed(xp: int, limit: int) -> void:
	SignalBus.xp_changed.emit(xp, limit)


func _on_level_gold_changed(amount: int) -> void:
	SignalBus.gold_changed.emit(amount)


func _on_building_placed(building: FactoryBuilding) -> void:
	var cfg := building.get_info().config
	if cfg == null or cfg.get("stat_name") == null:
		return
	var sid := StringName("pillar_%d_%d" % [building.position.x, building.position.y])
	player_stats.apply_modifier(sid, cfg.get("stat_name"), cfg.get("boost_value"))
	sync_stats()


func _on_building_removed(building: FactoryBuilding) -> void:
	var cfg := building.get_info().config
	if cfg == null or cfg.get("stat_name") == null:
		return
	var sid := StringName("pillar_%d_%d" % [building.position.x, building.position.y])
	player_stats.remove_modifier(sid, cfg.get("stat_name"))
	sync_stats()


func _apply_regen() -> void:
	var max_hp: float = player_stats.stats[&"max_health"].value
	var regen: float = player_stats.stats[&"health_regen"].value
	if regen <= 0:
		return
	var prev_health := health
	health = minf(health + regen, max_hp)
	var healed_amount := ceili(health - prev_health)
	if healed_amount > 0:
		SignalBus.healed.emit(healed_amount, &"regen")


func _on_player_died() -> void:
	_tick_timer.stop()
	_regen_timer.stop()
	set_physics_process(false)
	set_process_input(false)


func _shoot(item: FactoryItem = null) -> void:
	if item == null or item.shooting_strategy == null:
		return
	current_target = find_target()
	if current_target == null:
		return
	item.shooting_strategy.execute(self, current_target, item, player_stats)
