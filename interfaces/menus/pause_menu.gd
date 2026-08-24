class_name PauseMenu
extends InterfaceWindow

signal request_resume
signal request_quit

@export var resume_button: Button
@export var quit_button: Button


func _ready() -> void:
	resume_button.pressed.connect(request_resume.emit)
	quit_button.pressed.connect(request_quit.emit)
