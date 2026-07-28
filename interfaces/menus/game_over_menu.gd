class_name GameOverMenu
extends InterfaceWindow

## If [code]true[/code], shows win text instead of game over.
var is_win: bool

@export var return_button: Button
@onready var _title_label: Label = $ColorRect/Label


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)
	if is_win:
		_title_label.text = "Victory!"


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(&"uid://c0f8gqiflva8v")
