class_name DraggablePanel
extends PanelContainer

enum DraggingState {
	DROPPED,
	DRAGGING,
}

var _dragging_state: DraggingState = DraggingState.DROPPED

@onready var _top_bar := $VBoxContainer/TopBar


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		if _dragging_state == DraggingState.DRAGGING:
			self.position += event.relative
			return


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.is_released():
		_dragging_state = DraggingState.DROPPED
		return
	var tb_rect: Rect2 = _top_bar.get_viewport_rect()
	if event.is_pressed() and tb_rect.has_point(event.position):
		_dragging_state = DraggingState.DRAGGING
		return
