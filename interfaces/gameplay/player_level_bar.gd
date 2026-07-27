class_name PlayerLevelBar
extends Control

@export var bg_color: Color = Color(0, 0, 0, 0.5)
@export var fill_color: Color = Color(0.2, 0.6, 1.0)
@export var _fill: ColorRect
@export var _experience_label: Label


func setup(ls: LevelSystem) -> void:
	_lvl(ls.level)
	_xp_bar(ls.xp, ls.xp_to_next_level)
	ls.leveled_up.connect(_on_level_up)
	ls.xp_changed.connect(_on_xp_changed)


func _on_level_up(lvl: int) -> void:
	_lvl(lvl)


func _on_xp_changed(xp: int, limit: int) -> void:
	_xp_bar(xp, limit)


func _lvl(level: int) -> void:
	_experience_label.text = "Lv. %d" % level


func _xp_bar(xp: int, limit: int) -> void:
	if limit <= 0:
		_fill.anchor_right = 1.0
		return
	var ratio: float = float(xp) / float(limit)
	_fill.anchor_right = clampf(ratio, 0.0, 1.0)
