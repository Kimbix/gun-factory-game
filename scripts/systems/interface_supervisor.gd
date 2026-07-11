class_name InterfaceSupervisor
extends Node

signal pause_gameplay

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
		window_scene_uid: StringName,
		_source: Object = null,
) -> void:
	var open_in := interfaces[layer]
	var window_scene: PackedScene = load(window_scene_uid)
	var window_instance := window_scene.instantiate()
	open_in.add_child(window_instance)


func on_leveled_up(_new_level: int) -> void:
	pause_gameplay.emit()
	const LEVEL_UP_UID := &"uid://chiougv7mhwbp"
	open_interface(InterfaceType.EMERGENT, LEVEL_UP_UID, null)
