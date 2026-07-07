extends CanvasLayer

var opened_windows: Array[Control] = []
var focused_window: Control
var unfocusable_windows: Array[Control] = []

var _window_parent: Dictionary


func open_window(window: Control) -> void:
	add_child(window)
	opened_windows.append(window)
	focused_window = window


func open_window_from(window: Control, parent: Control) -> void:
	_window_parent[window] = parent
	parent.hide()
	opened_windows.erase(parent)
	open_window(window)


func is_interface_open() -> bool:
	return not opened_windows.is_empty()


func close_window(window: Control) -> void:
	var parent: Control = _window_parent.get(window)
	if parent != null:
		_window_parent.erase(window)
		parent.show()
		opened_windows.append(parent)
		focused_window = parent

	opened_windows.erase(window)
	unfocusable_windows.erase(window)
	if focused_window == window:
		focused_window = null
	window.queue_free()
