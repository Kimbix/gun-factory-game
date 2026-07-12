class_name GameSupervisor
extends Node

static var instance: GameSupervisor

var _paused: bool = false
var _active_player: SimpleCharacter
var _interface_supervisor: InterfaceSupervisor


func _ready() -> void:
	instance = self
	_active_player = %GameplayScene.player_instance
	_interface_supervisor = $InterfaceSupervisor

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
		_interface_supervisor.toggle_building_interface()
	if event.is_action_pressed("pause"):
		toggle_pause_gameplay()


func get_player() -> SimpleCharacter:
	return _active_player


func toggle_pause_gameplay() -> void:
	_paused = not _paused
	if _paused:
		%GameplayScene.process_mode = PROCESS_MODE_DISABLED
	else:
		%GameplayScene.process_mode = PROCESS_MODE_INHERIT


func unpause_gameplay() -> void:
	if not _paused:
		return
	toggle_pause_gameplay()


func pause_gameplay() -> void:
	if _paused:
		return
	toggle_pause_gameplay()


func _on_resume_requested() -> void:
	_paused = false
	%GameplayScene.process_mode = PROCESS_MODE_INHERIT
