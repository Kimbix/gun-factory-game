class_name EmergentUI
extends CanvasLayer

signal resume_requested


func show_level_up() -> void:
	%LevelUpNotification.show()


func _ready() -> void:
	%LevelUpNotification.resume_requested.connect(resume_requested.emit)
