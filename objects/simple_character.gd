class_name SimpleCharacter
extends CharacterBody2D

const SPEED := 200.0
const GRID_VIEW_SCALE := 1.5
const BULLET := preload("res://objects/bullet.tscn")

static var _actions_ready := false

@export var starting_grid_data: PlayerGridData

var _player_grid: PlayerGrid


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

	_player_grid = PlayerGrid.new()
	if starting_grid_data != null:
		_player_grid.from_data(starting_grid_data)
	else:
		_player_grid.initialize_empty()
	_player_grid.output_item.connect(_shoot)

	var tick_timer := Timer.new()
	tick_timer.timeout.connect(_player_grid.tick)
	tick_timer.wait_time = 0.05
	add_child(tick_timer)
	tick_timer.start()

	_setup_minimap()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
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


func _shoot(_item: FactoryItem = null) -> void:
	var bullet: Bullet = BULLET.instantiate()
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.global_position = global_position
	get_parent().add_child(bullet)
