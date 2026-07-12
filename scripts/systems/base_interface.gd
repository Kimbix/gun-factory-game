class_name BaseInterface
extends CanvasLayer

var windows: Array[InterfaceWindow]
var focused: InterfaceWindow


func open_window(window: InterfaceWindow, _window_parent: InterfaceWindow = null) -> void:
	self.add_child(window)
	windows.append(window)
	focused = window
	window.request_close.connect(close_window.bind(window))


func close_window(window: InterfaceWindow) -> void:
	if window == null:
		printerr("Attempted to close null window on layer %s" % self.name)
		return
	if not windows.has(window):
		printerr("Window %s does not exist on layer %s" % [window.name, self.name])
		return

	windows.erase(window)
	window.queue_free()
	if windows.size() > 0:
		focused = windows.back()
