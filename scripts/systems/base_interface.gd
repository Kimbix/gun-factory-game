class_name BaseInterface
extends CanvasLayer

var windows: Array[InterfaceWindow]
var focused: InterfaceWindow
var _hidden_parents: Dictionary[InterfaceWindow, InterfaceWindow]


func open_window(window: InterfaceWindow, window_parent: InterfaceWindow = null) -> bool:
	if window.source != null:
		for existing: InterfaceWindow in windows:
			if existing.source == window.source:
				_focus_window(existing)
				window.queue_free()
				return false

	self.add_child(window)
	windows.append(window)
	focused = window
	window.request_close.connect(close_window.bind(window))

	if window_parent != null:
		_hidden_parents[window] = window_parent
		window_parent.hide()
	return true


func _focus_window(window: InterfaceWindow) -> void:
	window.show()
	move_child(window, get_child_count() - 1)
	windows.erase(window)
	windows.append(window)
	focused = window


func close_window(window: InterfaceWindow) -> void:
	if window == null:
		printerr("Attempted to close null window on layer %s" % self.name)
		return
	if not windows.has(window):
		printerr("Window %s does not exist on layer %s" % [window.name, self.name])
		return

	windows.erase(window)
	window.queue_free()

	if _hidden_parents.has(window):
		var parent := _hidden_parents[window]
		_hidden_parents.erase(window)
		parent.show()

	if windows.size() > 0:
		focused = windows.back()
