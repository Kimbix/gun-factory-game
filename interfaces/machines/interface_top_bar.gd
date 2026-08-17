class_name TopBar
extends HBoxContainer

enum DraggingState {
	DROPPED,
	DRAGGING,
}

var _panel_parent: Control
var _dragging_state: DraggingState = DraggingState.DROPPED


func _ready() -> void:
	var looking: Control = self
	self.mouse_default_cursor_shape = Control.CURSOR_DRAG
	while true:
		if looking is InterfaceWindow:
			_panel_parent = looking
			break
		if looking is not Control or looking == null:
			break
		looking = looking.get_parent()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		if _dragging_state == DraggingState.DRAGGING:
			_panel_parent.position += event.relative
			return


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.is_released():
		_dragging_state = DraggingState.DROPPED
		return
	var self_rect: Rect2 = self.get_viewport_rect()
	if event.is_pressed() and self_rect.has_point(event.position):
		_dragging_state = DraggingState.DRAGGING
		return
