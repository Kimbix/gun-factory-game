class_name MetalProcessor
extends FactoryComponent

const CRAFT_TIME := 20
const INTERFACE := preload("uid://61ydd0a8m0ke")

var recipes = load("res://resources/recipes/metal_processor_recipes.tres")
var recipe: ItemRecipe
var lead_plates: int = 0
var _cooldown: int = 0
var _next_out_port: int = 0
var _interface: MetalProcessorInterface


func set_recipe(r: ItemRecipe) -> void:
	recipe = r


func tick() -> void:
	if recipe == null:
		_notify_progress(-1)
		return

	if _cooldown > 0:
		_cooldown -= 1
		_notify_progress(int((CRAFT_TIME - _cooldown) * 100.0 / CRAFT_TIME))
		if _cooldown == 0:
			var ports := grid.get_building_ports(position).filter(Port.output_mode_filter)
			if ports.is_empty():
				_cooldown = 1
				return
			for i in ports.size():
				var idx := (_next_out_port + i) % ports.size()
				var port: Port = ports[idx]
				if _can_output_to(recipe.outputs[0].item, port):
					_next_out_port = (idx + 1) % ports.size()
					_do_output(port)
					return
			_cooldown = 1
		return

	if lead_plates >= recipe.inputs[0].amount:
		lead_plates -= recipe.inputs[0].amount
		_cooldown = CRAFT_TIME


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
	grid.destroy_item(item)


func open_interface() -> void:
	var interface: MetalProcessorInterface = INTERFACE.instantiate()
	interface.metal_processor = self
	interface.recipes = recipes
	_interface = interface
	interface.tree_exited.connect(_on_interface_closed)
	_notify_progress(-1)
	InterfaceCanvasLayer.open_window(interface, self)


func _notify_progress(value: int) -> void:
	if _interface != null:
		_interface.update_completion(value)


func _do_output(port: Port) -> void:
	var where_to: Vector2 = position + port.position + port.facing
	grid.place_item(recipe.outputs[0].item, where_to)


func _on_interface_closed() -> void:
	_interface = null
