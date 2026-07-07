class_name AmmoAssembler
extends FactoryComponent

const INTERFACE := preload("res://interfaces/ammo_assembler_interface.tscn")

var RECIPES := load("res://resources/recipes/ammo_assembler_recipes.tres")
var inventory := BlockInventory.new(3)
var recipe: ItemRecipe
var _craft_progress: int = 0
var _interface: AmmoAssemblerInterface


func set_recipe(r: ItemRecipe) -> void:
	recipe = r
	_craft_progress = 0
	if r != null:
		var allowed: Array[FactoryItemInfo] = []
		for ingredient in r.inputs:
			allowed.append(ingredient.item)

		for slot_idx in inventory.slots.keys():
			if inventory.slots[slot_idx].item_info not in allowed:
				inventory.slots.erase(slot_idx)

		inventory.set_accept_filter(allowed)
	else:
		inventory.slots.clear()
		inventory.set_accept_filter([])


func tick() -> void:
	if recipe == null or not inventory.has_all(recipe.inputs):
		_craft_progress = 0
		_notify_progress(-1)
		return

	if not _can_output():
		_notify_progress(_craft_progress * 100 / 40)
		return

	_craft_progress += 1
	_notify_progress(_craft_progress * 100 / 40)
	if _craft_progress < 40:
		return

	_craft_progress = 0

	for ingredient in recipe.inputs:
		inventory.remove(ingredient.item, ingredient.amount)

	var output_port := _get_available_out_port()
	if output_port == null:
		return

	for output in recipe.outputs:
		var where := position + output_port.position + output_port.facing
		grid.place_item(output.item, where)


func _notify_progress(value: int) -> void:
	if _interface != null:
		_interface.update_completion(value)


func receive_item(item: FactoryItem) -> void:
	inventory.add(item)
	grid.destroy_item(item)


func open_interface() -> void:
	var interface: AmmoAssemblerInterface = INTERFACE.instantiate()
	interface.ammo_assembler = self
	interface.recipes = RECIPES
	_interface = interface
	interface.tree_exited.connect(_on_interface_closed)
	_notify_progress(-1)
	InterfaceCanvasLayer.open_window(interface)


func _on_interface_closed() -> void:
	_interface = null
