class_name PlayerHealthBar
extends Control

@export var bar_width: float = 48.0
@export var bar_height: float = 6.0
@export var y_offset: float = 24.0
@export var bg_color: Color = Color(0, 0, 0, 0.7)
@export var fill_color: Color = Color(0.8, 0.2, 0.2)

var player: SimpleCharacter

@onready var _background: ColorRect = %Background
@onready var _fill: ColorRect = %Fill


func setup(p: SimpleCharacter) -> void:
	player = p
	if player == null:
		return
	_refresh()


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var xform := camera.get_canvas_transform()
	var screen_pos := xform * (player.global_position + Vector2(0.0, y_offset))
	position = screen_pos - Vector2(bar_width / 2.0, 0.0)
	_refresh()


func _refresh() -> void:
	if player == null:
		return
	var max_hp: float = player.player_stats.stats[&"max_health"].value
	var ratio: float = player.health / max_hp if max_hp > 0 else 0.0
	_fill.anchor_right = clampf(ratio, 0.0, 1.0)
