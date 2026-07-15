class_name InterfaceSupervisor
extends Node

signal pause_requested
signal unpause_requested

enum InterfaceType {
	BUILDING,
	FACTORY_BUILDING,
	EMERGENT,
	DEBUG,
}

var interfaces: Dictionary[InterfaceType, BaseInterface]
var building_inventory: PlayerBuildingInventory
var _pending_level_ups: Array[int] = []
var _level_up_window_open: bool = false


func _ready() -> void:
	interfaces = { }
	for n: Node in get_children():
		if n is not BaseInterface:
			continue
		var n_name := n.name.to_lower()
		match n_name:
			&"buildingui":
				interfaces[InterfaceType.BUILDING] = n
			&"factorybuildingui":
				interfaces[InterfaceType.FACTORY_BUILDING] = n
			&"emergentui":
				interfaces[InterfaceType.EMERGENT] = n
			&"debugui":
				interfaces[InterfaceType.DEBUG] = n


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F3 and event.pressed and not event.echo:
		(interfaces[InterfaceType.DEBUG] as DebugUI).toggle_stats_debug()


func open_interface(
		layer: InterfaceType,
		window: InterfaceWindow,
		window_parent: InterfaceWindow = null,
) -> bool:
	var open_in := interfaces[layer]
	return open_in.open_window(window, window_parent)


func close_interface(
		layer: InterfaceType,
		window: InterfaceWindow,
) -> void:
	var close_in := interfaces[layer]
	close_in.close_window(window)


func on_leveled_up(_new_level: int) -> void:
	_pending_level_ups.append(_new_level)
	if not _level_up_window_open:
		_show_next_level_up()


func open_building_interface() -> void:
	(interfaces[InterfaceType.BUILDING] as BuildingUI).open_building_interface()


func close_building_interface() -> void:
	(interfaces[InterfaceType.BUILDING] as BuildingUI).close_building_interface()


func is_building_interface_open() -> bool:
	return (interfaces[InterfaceType.BUILDING] as BuildingUI).is_building_interface_open()


func _show_next_level_up() -> void:
	if _pending_level_ups.is_empty():
		_level_up_window_open = false
		unpause_requested.emit()
		return

	_pending_level_ups.pop_front()
	_level_up_window_open = true
	pause_requested.emit()
	var level_up_window := preload("uid://chiougv7mhwbp").instantiate()
	level_up_window.building_inventory = building_inventory
	level_up_window.on_closed = func():
		unpause_requested.emit()
	level_up_window.tree_exited.connect(_on_level_up_window_closed)
	open_interface(InterfaceType.EMERGENT, level_up_window, null)


func _on_level_up_window_closed() -> void:
	_show_next_level_up()
