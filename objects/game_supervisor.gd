class_name GameSupervisor
extends Node

var _building: bool = false
var _paused: bool = false
var _emergent_ui: EmergentUI
var _active_player: SimpleCharacter
var _interface_supervisor: InterfaceSupervisor


func _ready() -> void:
	_active_player = %GameplayScene.player_instance
	call_deferred("_connect_level_system")

	_interface_supervisor = $InterfaceSupervisor
	_interface_supervisor.player = _active_player

	_emergent_ui = %EmergentUI as EmergentUI
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("factory_building"):
		pause_gameworld()
		bring_building_interface()
	if event.is_action_pressed("pause"):
		pause_gameworld()


func bring_building_interface() -> void:
	_building = not _building
	if _building:
		%BuildingUI.open_factory_interface(%GameplayScene.player_instance.player_grid)
	else:
		%BuildingUI.close_factory_interface()


func pause_gameworld() -> void:
	_paused = not _paused
	if _paused:
		%GameplayScene.process_mode = PROCESS_MODE_DISABLED
	else:
		%GameplayScene.process_mode = PROCESS_MODE_INHERIT


func _connect_level_system() -> void:
	var player := _active_player
	if player == null:
		return
	player.level_system.leveled_up.connect(_on_leveled_up)
	if _emergent_ui != null:
		_emergent_ui.resume_requested.connect(_on_resume_requested)


func _on_leveled_up(_new_level: int) -> void:
	_paused = true
	%GameplayScene.process_mode = PROCESS_MODE_DISABLED
	if _emergent_ui != null:
		_emergent_ui.show_level_up()


func _on_resume_requested() -> void:
	_paused = false
	%GameplayScene.process_mode = PROCESS_MODE_INHERIT
