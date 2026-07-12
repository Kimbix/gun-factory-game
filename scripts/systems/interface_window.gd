class_name InterfaceWindow
extends Control

signal request_close

var window_parent: InterfaceWindow


func close_self() -> void:
	request_close.emit()
