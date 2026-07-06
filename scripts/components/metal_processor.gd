class_name MetalProcessor
extends FactoryComponent

const CRAFT_TIME := 60
const INTERFACE := preload("uid://61ydd0a8m0ke")

var recipe: ItemRecipe
var lead_plates: int = 0
var _cooldown: int = 0


func tick() -> void:
	if recipe == null:
		return

	if _cooldown > 0:
		_cooldown -= 1
		if _cooldown == 0:
			if _can_output():
				_do_output()
			else:
				_cooldown = 1
		return

	if lead_plates >= recipe.inputs[0].amount:
		lead_plates -= recipe.inputs[0].amount
		_cooldown = CRAFT_TIME


func _do_output() -> void:
	var p := _get_available_out_port()
	if p == null:
		return
	var where_to: Vector2 = position + p.position + p.facing
	grid.place_item(recipe.outputs[0].item, where_to)


func receive_item(item: FactoryItem) -> void:
	if item.name == &"lead_plate":
		lead_plates += 1
	grid.destroy_item(item)


func open_interface() -> void:
	var interface: MetalProcessorInterface = INTERFACE.instantiate()
	InterfaceCanvasLayer.add_child(interface)
	var _on_recipe_pressed: Callable = func(r: ItemRecipe) -> void:
		recipe = r
		interface.change_recipe(recipe)
	interface.recipe_selected.connect(_on_recipe_pressed)
	interface.change_recipe(recipe)
