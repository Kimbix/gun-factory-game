class_name MetalProcessor
extends FactoryComponent

var recipe: ItemRecipe
var lead_plates: int = 0
var _cooldown: int = 0
var _next_out_port: int = 0


func set_recipe(r: ItemRecipe) -> void:
	recipe = r
	_update_overlay_strategy()


func tick() -> void:
	if recipe == null:
		_notify_progress(-1, 0)
		_notify_inventory()
		return

	if _cooldown > 0:
		_cooldown -= 1
		_notify_progress(recipe.craft_time - _cooldown, recipe.craft_time)
		if _cooldown == 0:
			var g := grid
			if g == null:
				return
			var ports := g.get_building_ports(position).filter(Port.output_mode_filter)
			if ports.is_empty():
				_cooldown = 1
				return
			for i in ports.size():
				var idx := (_next_out_port + i) % ports.size()
				var port: Port = ports[idx]
				if _output_item(recipe.outputs[0].item, port):
					_next_out_port = (idx + 1) % ports.size()
					return
			_cooldown = 1
		_notify_inventory()
		return

	if lead_plates >= recipe.inputs[0].amount:
		lead_plates -= recipe.inputs[0].amount
		_cooldown = recipe.craft_time

	_notify_inventory()


func get_vars() -> Dictionary:
	return {
		&"recipe": recipe,
		&"lead_plates": lead_plates,
		&"_cooldown": _cooldown,
		&"_next_out_port": _next_out_port,
	}


func receive_item(item: FactoryItem) -> void:
	if item.name == &"lead_plate":
		lead_plates += 1
	var g := grid
	if g == null:
		return
	g.destroy_item(item)


func set_var(n: StringName, v: Variant) -> void:
	match n:
		&"recipe":
			set_recipe(v)
		_:
			super.set_var(n, v)


func open_interface(interface_supervisor: InterfaceSupervisor) -> void:
	var cfg := building.get_info().config as MachineConfig
	var interface: MetalProcessorInterface = cfg.interface_scene.instantiate()
	interface.metal_processor = self
	interface.recipes = cfg.recipe_catalogue
	interface.source = self
	interface.interface_supervisor = interface_supervisor
	if not interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
		interface,
	):
		return
	_progress_interface = interface
	interface.tree_exited.connect(_on_interface_closed)
	_notify_progress(-1, recipe.craft_time if recipe != null else 0)


func _update_overlay_strategy() -> void:
	if recipe == null or recipe.outputs.is_empty():
		overlay_strategy = null
		return
	var s := ItemOverlayStrategy.new()
	s.item_info = recipe.outputs[0].item
	overlay_strategy = s
