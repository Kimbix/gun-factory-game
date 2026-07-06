class_name AmmoAssembler
extends FactoryComponent

const INTERFACE := preload("res://interfaces/ammo_assembler_interface.tscn")

var inventory := BlockInventory.new(3)
var recipe: ItemRecipe


func set_recipe(r: ItemRecipe) -> void:
	recipe = r
	if r != null:
		var allowed: Array[FactoryItemInfo] = []
		for ingredient in r.inputs:
			allowed.append(ingredient.item)
		inventory.set_accept_filter(allowed)


func tick() -> void:
	pass


func receive_item(item: FactoryItem) -> void:
	inventory.add(item)
	grid.destroy_item(item)


func open_interface() -> void:
	var interface: AmmoAssemblerInterface = INTERFACE.instantiate()
	InterfaceCanvasLayer.add_child(interface)
	var _on_recipe_pressed: Callable = func(r: ItemRecipe) -> void:
		recipe = r
		interface.change_recipe(recipe)
	interface.recipe_selected.connect(_on_recipe_pressed)
	interface.change_recipe(recipe)
