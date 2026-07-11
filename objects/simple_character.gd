class_name SimpleCharacter
extends CharacterBody2D

const GRID_VIEW_SCALE := 1.5

static var _actions_ready := false

@export var starting_grid_data: PlayerGridData

var current_target: Node2D
var _player_grid: PlayerGrid
var building_inventory: PlayerBuildingInventory
var level_system: LevelSystem
var player_stats: PlayerStats
var health: float
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

	player_stats = PlayerStats.new(PlayerStatsData.new())
	health = player_stats.stats[&"max_health"].value

	add_to_group("player")

	_player_grid = PlayerGrid.new()
	_player_grid.output_item.connect(_shoot)
	_player_grid.building_placed.connect(_on_building_placed)
	_player_grid.building_removed.connect(_on_building_removed)

	_tick_timer = Timer.new()
	_tick_timer.timeout.connect(_player_grid.tick)
	_tick_timer.wait_time = player_stats.stats[&"tick_speed"].value
	add_child(_tick_timer)

	_regen_timer = Timer.new()
	_regen_timer.timeout.connect(_apply_regen)
	_regen_timer.wait_time = 1.0
	add_child(_regen_timer)

	if starting_grid_data != null:
		_player_grid.from_data(starting_grid_data)
	else:
		_player_grid.initialize_empty()

	_tick_timer.start()
	_regen_timer.start()

	_setup_minimap()
	sync_stats()

	$CollectionArea.area_entered.connect(_on_collection_area_entered)


func _on_collection_area_entered(area: Area2D) -> void:
	var crystal := area as ExperienceCrystal
	if crystal == null:
		return
	crystal.collected.connect(_on_crystal_collected.bind(crystal))
	crystal.start_follow(self)


func _on_crystal_collected(crystal: ExperienceCrystal) -> void:
	level_system.add_xp(crystal.xp_value)


func _on_level_up(new_level: int) -> void:
	print("Level ", new_level, "!")


func _on_building_placed(building: FactoryBuilding) -> void:
	var info := building.get_info()
	if info.stat_name == &"":
		return
	var sid := StringName("pillar_%d_%d" % [building.position.x, building.position.y])
	player_stats.apply_modifier(sid, info.stat_name, info.boost_value)
	sync_stats()


func _on_building_removed(building: FactoryBuilding) -> void:
	var info := building.get_info()
	if info.stat_name == &"":
		return
	var sid := StringName("pillar_%d_%d" % [building.position.x, building.position.y])
	player_stats.remove_modifier(sid, info.stat_name)
	sync_stats()


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


func _apply_regen() -> void:
	var max_hp: float = player_stats.stats[&"max_health"].value
	var regen: float = player_stats.stats[&"health_regen"].value
	if regen <= 0:
		return
	health = minf(health + regen, max_hp)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_stats.stats[&"move_speed"].value
	move_and_slide()


func _setup_minimap() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var viewer := PlayerGridViewer.new()
	viewer.grid = _player_grid
	layer.add_child(viewer)

	var grid_w := _player_grid.dimensions.x * PlayerGrid.GRID_TEXTURE_SIZE
	viewer.position = Vector2(get_viewport().get_visible_rect().size.x - grid_w * GRID_VIEW_SCALE - 10, 10)
	viewer.scale = Vector2(GRID_VIEW_SCALE, GRID_VIEW_SCALE)


func _shoot(item: FactoryItem = null) -> void:
	if item == null or item.shooting_strategy == null:
		return
	current_target = find_target()
	if current_target == null:
		return
	item.shooting_strategy.execute(self, current_target, item)


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
