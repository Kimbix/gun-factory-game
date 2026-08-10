class_name Furnace
extends FactoryComponent

const CRAFT_TIME := 30

var lead_count: int = 0
var _cooldown: int = 0


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
			if not (_can_output() and _output_item(output)):
				_cooldown = 1
				_update_progress()
		return

	if lead_count > 0:
		lead_count -= 1
		_cooldown = CRAFT_TIME
	else:
		_update_progress()


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


func get_input_count() -> int:
	return lead_count


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
	_progress_interface = interface
	interface.tree_exited.connect(_on_interface_closed)
	_update_progress()


func _update_progress() -> void:
	if _progress_interface == null:
		return
	var progress := CRAFT_TIME - _cooldown if _cooldown > 0 else -1
	_progress_interface.update_completion(progress, CRAFT_TIME)
	_notify_inventory()
