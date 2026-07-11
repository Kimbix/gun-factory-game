class_name GameSupervisor
extends Node

var _paused: bool = false


func _ready() -> void:
	if not InputMap.has_action("pause"):
		var event := InputEventKey.new()
		event.keycode = KEY_ESCAPE
		InputMap.add_action("pause")
		InputMap.action_add_event("pause", event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
