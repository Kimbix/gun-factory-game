class_name GameTimer
extends Control

@export var _label: Label

var game_director: GameDirector


static func _format_time(seconds: float) -> String:
	var total := int(seconds)
	var m := total / 60.0
	var s := total % 60
	return "%02d:%02d" % [m, s]


func _process(_delta: float) -> void:
	if not is_instance_valid(game_director):
		return
	_label.text = _format_time(game_director.elapsed_time)


func setup(director: GameDirector) -> void:
	game_director = director
