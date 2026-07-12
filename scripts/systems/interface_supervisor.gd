class_name InterfaceSupervisor
extends Node

enum InterfaceType {
	BUILDING,
	FACTORY_BUILDING,
	EMERGENT,
	DEBUG,
}

static var instance: InterfaceSupervisor

var interfaces: Dictionary[InterfaceType, BaseInterface]


func _ready() -> void:
	instance = self
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
	GameSupervisor.instance.pause_gameplay()
	var level_up_window := preload("uid://chiougv7mhwbp").instantiate()
	open_interface(InterfaceType.EMERGENT, level_up_window, null)


func open_building_interface() -> void:
	(interfaces[InterfaceType.BUILDING] as BuildingUI).open_building_interface()


func close_building_interface() -> void:
	(interfaces[InterfaceType.BUILDING] as BuildingUI).close_building_interface()


func is_building_interface_open() -> bool:
	return (interfaces[InterfaceType.BUILDING] as BuildingUI).is_building_interface_open()
