extends CharacterBody2D

const SPEED := 200.0

@export var starting_grid_data: PlayerGridData

var _player_grid: PlayerGrid

static var _actions_ready := false


func _ready() -> void:
	if not _actions_ready:
		_setup_input_actions()
		_actions_ready = true

	_player_grid = PlayerGrid.new()
	if starting_grid_data != null:
		_player_grid.from_data(starting_grid_data)
	else:
		_player_grid.initialize_empty()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_shoot()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()


func _shoot() -> void:
	var bullet := Bullet.new()
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.global_position = global_position
	get_parent().add_child(bullet)


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
