class_name GameOverMenu
extends InterfaceWindow

@export var return_button: Button


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(&"uid://c0f8gqiflva8v")
