class_name GameSupervisor
extends Node

var _paused: bool = false


func _ready() -> void:
	if not InputMap.has_action("pause"):
		var event := InputEventKey.new()
		event.keycode = KEY_ESCAPE
		InputMap.add_action("pause")
		InputMap.action_add_event("pause", event)

	call_deferred("_connect_level_system")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	_paused = not _paused
	if _paused:
		%GameplayScene.process_mode = PROCESS_MODE_DISABLED
	else:
		%GameplayScene.process_mode = PROCESS_MODE_INHERIT


func _connect_level_system() -> void:
	var player := get_tree().get_first_node_in_group("player") as SimpleCharacter
	if player == null:
		return
	player.level_system.leveled_up.connect(_on_leveled_up)
	%LevelUpNotification.resume_requested.connect(_on_resume_requested)


func _on_leveled_up(_new_level: int) -> void:
	_paused = true
	%GameplayScene.process_mode = PROCESS_MODE_DISABLED
	%LevelUpNotification.show()


func _on_resume_requested() -> void:
	_paused = false
	%GameplayScene.process_mode = PROCESS_MODE_INHERIT
