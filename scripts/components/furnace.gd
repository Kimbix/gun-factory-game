class_name Furnace
extends FactoryComponent

const CRAFT_TIME := 30

var lead_count: int = 0
var _cooldown: int = 0
var _interface: FurnaceInterface


func setup() -> void:
	var s := ItemOverlayStrategy.new()
	s.item_info = (building.get_info().config as MachineConfig).output_item
	overlay_strategy = s


func tick() -> void:
	var output := (building.get_info().config as MachineConfig).output_item
	if _cooldown > 0:
		_cooldown -= 1
		_update_progress()
		if _cooldown == 0:
			var port := _get_available_out_port()
			if port != null and _can_output() and _can_output_to(output, port):
				_do_output()
			else:
				_cooldown = 1
				_update_progress()
		return

	if lead_count > 0:
		lead_count -= 1
		_cooldown = CRAFT_TIME
	else:
		_update_progress()


func _do_output() -> void:
	var p := _get_available_out_port()
	if p == null:
		return
	var g := grid
	if g == null:
		return
	var output := (building.get_info().config as MachineConfig).output_item
	var where_to: Vector2 = position + p.position + p.facing
	g.place_item(FactoryItem.new(output, where_to))


func get_vars() -> Dictionary:
	return {
		&"lead_count": lead_count,
		&"_cooldown": _cooldown,
	}


func receive_item(item: FactoryItem) -> void:
	if item.name == &"raw_lead":
		lead_count += 1
	var g := grid
	if g == null:
		return
	g.destroy_item(item)


func open_interface(interface_supervisor: InterfaceSupervisor) -> void:
	var cfg := building.get_info().config as MachineConfig
	var interface: FurnaceInterface = cfg.interface_scene.instantiate()
	interface.furnace = self
	interface.source = self
	if not interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
		interface,
	):
		return
	_interface = interface
	interface.tree_exited.connect(_on_furnace_interface_closed)
	_update_progress()


func _on_furnace_interface_closed() -> void:
	_interface = null


func _update_progress() -> void:
	if _interface == null:
		return
	var progress := CRAFT_TIME - _cooldown if _cooldown > 0 else -1
	_interface.update_completion(progress, CRAFT_TIME)
