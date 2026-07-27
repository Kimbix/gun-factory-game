class_name PlayerLevelBar
extends Control

@export var bg_color: Color = Color(0, 0, 0, 0.5)
@export var fill_color: Color = Color(0.2, 0.6, 1.0)
@export var _fill: ColorRect
@export var _experience_label: Label

var level_system: LevelSystem


func setup(ls: LevelSystem) -> void:
	level_system = ls
	if level_system == null:
		return
	level_system.leveled_up.connect(func(_lvl: int): _refresh())
	level_system.xp_changed.connect(func(_xp: int, _limit: int): _refresh())
	_refresh()


func _refresh() -> void:
	if level_system == null:
		return
	_experience_label.text = "Lv. %d" % level_system.level
	if level_system.xp_to_next_level <= 0:
		_fill.anchor_right = 1.0
		return
	var ratio: float = float(level_system.xp) / float(level_system.xp_to_next_level)
	_fill.anchor_right = clampf(ratio, 0.0, 1.0)
