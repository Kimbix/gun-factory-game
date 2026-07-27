class_name GameSupervisor
extends Node

enum GameState {
	GAMEPLAY,
	BUILDING,
	LEVEL_UP,
	PAUSED,
	GAME_OVER,
}

var _state: GameState = GameState.GAMEPLAY
var _state_before_pause: GameState = GameState.GAMEPLAY
var _state_before_level_up: GameState = GameState.GAMEPLAY
var _active_player: SimpleCharacter
var _interface_supervisor: InterfaceSupervisor
var _pause_menu_instance: PauseMenu
var _game_over_menu_instance: InterfaceWindow

@onready var _building_ui: BuildingUI = $InterfaceSupervisor/BuildingUI
@onready var _grid_builder: GridBuilder = (
		$InterfaceSupervisor/BuildingUI/PlayerGridViewer/GridBuilder
)
@onready var _grid_interactor: GridInteractor = (
		$InterfaceSupervisor/BuildingUI/PlayerGridViewer/GridInteractor
)
@onready var _overlay_ui: OverlayUI = $InterfaceSupervisor/OverlayUI


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
	_interface_supervisor.pause_requested.connect(pause_for_level_up)
	_interface_supervisor.unpause_requested.connect(unpause_from_level_up)
	_active_player.leveled_up.connect(_interface_supervisor.on_leveled_up)
	_active_player.died.connect(_on_player_died)

	_overlay_ui.setup(_active_player.level_system)

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
	if event.is_action_pressed("pause"):
		if _state not in [GameState.GAMEPLAY, GameState.BUILDING, GameState.PAUSED]:
			return
		match _state:
			GameState.GAMEPLAY, GameState.BUILDING:
				_state_before_pause = _state
				_set_state(GameState.PAUSED)
			GameState.PAUSED:
				_set_state(_state_before_pause)
		return

	if event.is_action_pressed("factory_building"):
		if _state not in [GameState.GAMEPLAY, GameState.BUILDING]:
			return
		match _state:
			GameState.GAMEPLAY:
				_set_state(GameState.BUILDING)
			GameState.BUILDING:
				_set_state(GameState.GAMEPLAY)
		return

	if event.is_action_pressed("building_overlay"):
		if _state != GameState.BUILDING:
			return
		var viewer := _building_ui.player_grid_viewer
		viewer.building_overlay = not viewer.building_overlay
		viewer.queue_redraw()


func get_player() -> SimpleCharacter:
	return _active_player


func pause_for_level_up() -> void:
	_state_before_level_up = _state
	_set_state(GameState.LEVEL_UP)


func unpause_from_level_up() -> void:
	_set_state(_state_before_level_up)


func unpause() -> void:
	if _state == GameState.PAUSED:
		_set_state(_state_before_pause)


func _show_pause_menu() -> void:
	_pause_menu_instance = preload("res://interfaces/menus/pause_menu.tscn").instantiate()
	_interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_pause_menu_instance,
	)


func _hide_pause_menu() -> void:
	if not is_instance_valid(_pause_menu_instance):
		return
	_interface_supervisor.close_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_pause_menu_instance,
	)
	_pause_menu_instance = null


func _show_game_over_menu() -> void:
	if is_instance_valid(_game_over_menu_instance):
		return
	_game_over_menu_instance = preload("res://interfaces/menus/game_over_menu.tscn").instantiate()
	_interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_game_over_menu_instance,
	)


func _hide_game_over_menu() -> void:
	if not is_instance_valid(_game_over_menu_instance):
		return
	_interface_supervisor.close_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_game_over_menu_instance,
	)
	_game_over_menu_instance = null


func _on_player_died() -> void:
	_set_state(GameState.GAME_OVER)


func _set_state(new_state: GameState) -> void:
	if new_state == _state:
		return
	_state = new_state

	match new_state:
		GameState.GAMEPLAY:
			_hide_pause_menu()
			_interface_supervisor.close_building_interface()
			%GameplayScene.process_mode = PROCESS_MODE_INHERIT
		GameState.BUILDING:
			_hide_pause_menu()
			_interface_supervisor.open_building_interface()
			%GameplayScene.process_mode = PROCESS_MODE_DISABLED
		GameState.LEVEL_UP:
			_hide_pause_menu()
			%GameplayScene.process_mode = PROCESS_MODE_DISABLED
			_building_ui.process_mode = PROCESS_MODE_DISABLED
		GameState.PAUSED:
			%GameplayScene.process_mode = PROCESS_MODE_DISABLED
			_show_pause_menu()
		GameState.GAME_OVER:
			_hide_pause_menu()
			_interface_supervisor.close_building_interface()
			%GameplayScene.process_mode = PROCESS_MODE_DISABLED
			_show_game_over_menu()
