class_name TopBar
extends HBoxContainer

enum DraggingState {
	DROPPED,
	DRAGGING,
}

@export var _panel_parent: Control
@export var _title: String:
	get():
		return _title
	set(v):
		_title = v
		if is_instance_valid(_panel_label):
			_panel_label.text = v

var _dragging_state: DraggingState = DraggingState.DROPPED

## This works with the scene "res://interfaces/machines/interface_top_bar.tscn"
@onready var _panel_label: Label = $Tilte
@onready var _close_button: Button = $Close


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
