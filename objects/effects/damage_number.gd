class_name DamageNumber
extends Node2D

const FLOAT_HEIGHT := -40.0
const DURATION := 1.2

@onready var _label: Label = $Label


func play(text: String, color: Color, world_position: Vector2) -> void:
	global_position = world_position
	_label.text = text
	_label.modulate = color
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	var target := global_position + Vector2(0, FLOAT_HEIGHT)
	tween.tween_property(self, "global_position", target, DURATION)
	tween.parallel().tween_property(_label, "modulate:a", 0.0, DURATION)
	tween.finished.connect(DamageNumberPool.free_number.bind(self))
