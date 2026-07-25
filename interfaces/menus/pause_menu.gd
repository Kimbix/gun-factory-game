class_name PauseMenu
extends InterfaceWindow

@export var resume_button: Button
@export var quit_button: Button


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_resume_pressed() -> void:
	var supervisor := get_tree().current_scene as GameSupervisor
	supervisor.unpause()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file(&"uid://c0f8gqiflva8v")
