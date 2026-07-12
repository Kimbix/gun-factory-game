extends BaseInterface

var opened_windows: Array[Control] = []
var focused_window: Control
var unfocusable_windows: Array[Control] = []
var _window_parent: Dictionary
var _source_to_window: Dictionary = { }


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and focused_window != null:
		close_window(focused_window)
		get_viewport().set_input_as_handled()


func open_window(window: InterfaceWindow, window_parent: InterfaceWindow = null) -> bool:
	if not super.open_window(window, window_parent):
		return false
	opened_windows.append(window)
	focused_window = window
	window.gui_input.connect(_on_window_gui_input.bind(window))
	return true


func _focus_window(window: InterfaceWindow) -> void:
	super._focus_window(window)
	opened_windows.erase(window)
	opened_windows.append(window)
	focused_window = window


func is_interface_open() -> bool:
	return not opened_windows.is_empty()


func close_window(window: InterfaceWindow) -> void:
	var source_to_remove: Object = null
	for s in _source_to_window:
		if _source_to_window[s] == window:
			source_to_remove = s
			break
	if source_to_remove != null:
		_source_to_window.erase(source_to_remove)

	var parent: Control = _window_parent.get(window)
	if parent != null:
		_window_parent.erase(window)
		parent.show()
		opened_windows.append(parent)
		focused_window = parent

	opened_windows.erase(window)
	unfocusable_windows.erase(window)
	if focused_window == window:
		focused_window = opened_windows.back() if not opened_windows.is_empty() else null

	super.close_window(window)


func _on_window_gui_input(event: InputEvent, window: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		focused_window = window
