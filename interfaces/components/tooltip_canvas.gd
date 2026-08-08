class_name TooltipCanvas
extends CanvasLayer

const TOOLTIP_SCENE := preload("uid://cvqwglrao0p5n")

var _current_tooltip: Tooltip


func show_tooltip(text: String, position: Vector2) -> void:
	if _current_tooltip == null:
		_current_tooltip = TOOLTIP_SCENE.instantiate()
		add_child(_current_tooltip)
	_current_tooltip.set_text(text)
	_current_tooltip.position = position
	_current_tooltip.visible = true


func hide_tooltip() -> void:
	if _current_tooltip != null:
		_current_tooltip.visible = false
