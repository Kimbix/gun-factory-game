class_name MetalProcessor
extends FactoryComponent

const CRAFT_TIME := 60
const INTERFACE := preload("uid://61ydd0a8m0ke")

var recipes = load("res://resources/recipes/metal_processor_recipes.tres")
var recipe: ItemRecipe
var lead_plates: int = 0
var _cooldown: int = 0
var _interface: MetalProcessorInterface


func set_recipe(r: ItemRecipe) -> void:
	recipe = r


func tick() -> void:
	if recipe == null:
		_notify_progress(-1)
		return

	if _cooldown > 0:
		_cooldown -= 1
		_notify_progress((CRAFT_TIME - _cooldown) * 100 / CRAFT_TIME)
		if _cooldown == 0:
			if _can_output():
				_do_output()
			else:
				_cooldown = 1
		return

	if lead_plates >= recipe.inputs[0].amount:
		lead_plates -= recipe.inputs[0].amount
		_cooldown = CRAFT_TIME


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
	InterfaceCanvasLayer.open_window(interface)


func _notify_progress(value: int) -> void:
	if _interface != null:
		_interface.update_completion(value)


func _do_output() -> void:
	var p := _get_available_out_port()
	if p == null:
		return
	var where_to: Vector2 = position + p.position + p.facing
	grid.place_item(recipe.outputs[0].item, where_to)


func _on_interface_closed() -> void:
	_interface = null
