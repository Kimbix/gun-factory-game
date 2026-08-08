## Autoload that manages a single [Tooltip] instance that follows the mouse.
extends CanvasLayer

const TOOLTIP_SCENE := preload("uid://cvqwglrao0p5n")
## Pixel offset from the mouse cursor.
const OFFSET := Vector2(12, 12)

var _current_tooltip: Tooltip


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		hide_tooltip()


func _process(_delta: float) -> void:
	if _current_tooltip != null and _current_tooltip.visible:
		_current_tooltip.position = get_viewport().get_mouse_position() + OFFSET


## Shows a tooltip with [param text] at the mouse cursor.
func show_tooltip(text: String) -> void:
	if _current_tooltip == null:
		_current_tooltip = TOOLTIP_SCENE.instantiate()
		add_child(_current_tooltip)
	_current_tooltip.set_text(text)
	_current_tooltip.visible = true


## Hides the current tooltip.
func hide_tooltip() -> void:
	if _current_tooltip != null:
		_current_tooltip.visible = false
