class_name MainMenu
extends CanvasLayer

const GAME_SCENE := &"uid://d2iffoyfe2cd2"

@onready var play_button: Button = $PlayButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_selected)


func _on_play_selected() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
