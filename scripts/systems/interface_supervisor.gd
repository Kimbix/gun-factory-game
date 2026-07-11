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
var player: SimpleCharacter


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


func open_interface(layer: InterfaceType, window: Control, source: Object = null) -> void:
	pass
