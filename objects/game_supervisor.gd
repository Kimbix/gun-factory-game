class_name GameSupervisor
extends Node

enum GameState {
	GAMEPLAY,
	BUILDING,
	PAUSED,
}

var _state: GameState = GameState.GAMEPLAY
var _state_before_pause: GameState = GameState.GAMEPLAY
var _active_player: SimpleCharacter
var _interface_supervisor: InterfaceSupervisor

@onready var _building_ui: BuildingUI = $InterfaceSupervisor/BuildingUI
@onready var _grid_builder: GridBuilder = (
		$InterfaceSupervisor/BuildingUI/PlayerGridViewer/GridBuilder
)
@onready var _grid_interactor: GridInteractor = (
		$InterfaceSupervisor/BuildingUI/PlayerGridViewer/GridInteractor
)


func _ready() -> void:
	_active_player = %GameplayScene.player_instance
	_interface_supervisor = $InterfaceSupervisor

	_building_ui.player_grid = _active_player.player_grid
	_building_ui.building_inventory = _active_player.building_inventory
	_building_ui.grid_builder = _grid_builder

	_grid_builder.building_inventory = _active_player.building_inventory
	_grid_builder.building_ui = _building_ui

	_grid_interactor.building_inventory = _active_player.building_inventory
	_grid_interactor.builder = _grid_builder
	_grid_interactor.building_ui = _building_ui
	_grid_interactor.interface_supervisor = _interface_supervisor

	_interface_supervisor.building_inventory = _active_player.building_inventory
	_interface_supervisor.on_pause_requested = pause_gameplay
	_interface_supervisor.on_unpause_requested = unpause_gameplay
	_active_player.leveled_up.connect(_interface_supervisor.on_leveled_up)

	if not InputMap.has_action("pause"):
		var event := InputEventKey.new()
		event.keycode = KEY_P
		InputMap.add_action("pause")
		InputMap.action_add_event("pause", event)

	if not InputMap.has_action("factory_building"):
		var event := InputEventKey.new()
		event.keycode = KEY_F
		InputMap.add_action("factory_building")
		InputMap.action_add_event("factory_building", event)

	if not InputMap.has_action("building_overlay"):
		var event := InputEventKey.new()
		event.keycode = KEY_ALT
		InputMap.add_action("building_overlay")
		InputMap.action_add_event("building_overlay", event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("factory_building"):
		match _state:
			GameState.GAMEPLAY:
				_set_state(GameState.BUILDING)
			GameState.BUILDING:
				_set_state(GameState.GAMEPLAY)

	if event.is_action_pressed("building_overlay") and _state == GameState.BUILDING:
		var viewer := _building_ui.player_grid_viewer
		viewer.building_overlay = not viewer.building_overlay
		viewer.queue_redraw()

	if event.is_action_pressed("pause"):
		match _state:
			GameState.GAMEPLAY, GameState.BUILDING:
				_state_before_pause = _state
				_set_state(GameState.PAUSED)
			GameState.PAUSED:
				_set_state(_state_before_pause)


func get_player() -> SimpleCharacter:
	return _active_player


func pause_gameplay() -> void:
	%GameplayScene.process_mode = PROCESS_MODE_DISABLED


func unpause_gameplay() -> void:
	if _state == GameState.GAMEPLAY:
		%GameplayScene.process_mode = PROCESS_MODE_INHERIT


func _set_state(new_state: GameState) -> void:
	if new_state == _state:
		return
	_state = new_state

	match new_state:
		GameState.GAMEPLAY:
			_interface_supervisor.close_building_interface()
			%GameplayScene.process_mode = PROCESS_MODE_INHERIT
		GameState.BUILDING:
			_interface_supervisor.open_building_interface()
			%GameplayScene.process_mode = PROCESS_MODE_DISABLED
		GameState.PAUSED:
			%GameplayScene.process_mode = PROCESS_MODE_DISABLED
