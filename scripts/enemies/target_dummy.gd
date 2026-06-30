class_name TargetDummy
extends StaticBody2D

var _base_modulate: Color


func _ready() -> void:
	_base_modulate = modulate


func hit(stats: Dictionary) -> void:
	var damage: float = stats.get("damage", 1.0) + stats.get("damage_bonus", 0.0)
	_spawn_number(damage)
	var tween := create_tween()
	tween.tween_method(_flash, 1.0, 0.0, 0.1)
	tween.tween_callback(_reset_flash)


func _flash(amount: float) -> void:
	modulate = Color.WHITE.lerp(Color.RED, amount)


func _reset_flash() -> void:
	modulate = _base_modulate


func _spawn_number(value: float) -> void:
	var label := Label.new()
	label.text = str(int(value))
	label.add_theme_font_size_override(&"font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-20, -24)
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 16, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.finished.connect(label.queue_free)
