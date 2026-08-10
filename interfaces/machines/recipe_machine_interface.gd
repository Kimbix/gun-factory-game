class_name RecipeMachineInterface
extends InterfaceWindow

const ITEM_WITH_COUNT := preload("res://interfaces/components/item_with_count.tscn")
const RECIPE_PICKER := preload("uid://0xiqunpp8bx8")

@export var close_button: Button
@export var selected_recipe: Button
@export var items_in_inventory: HBoxContainer
@export var completion_label: Label
@export var interface_supervisor: InterfaceSupervisor

var recipes: BaseRecipeCatalogue
var _picker: RecipePickerInterface
var machine: Variant
var _ingredient_displays: Array[ItemWithCount] = []


func _ready() -> void:
	close_button.pressed.connect(close_self)
	selected_recipe.pressed.connect(_on_selected_recipe)


func generate_ui() -> void:
	for child in items_in_inventory.get_children():
		child.queue_free()
	_ingredient_displays.clear()

	var current_recipe := _get_recipe()
	if current_recipe == null:
		selected_recipe.text = "?"
		selected_recipe.icon = null
		selected_recipe.expand_icon = true
		var label := Label.new()
		label.text = "No Recipe Selected"
		items_in_inventory.add_child(label)
		return

	selected_recipe.text = ""
	selected_recipe.icon = current_recipe.icon
	selected_recipe.expand_icon = true
	selected_recipe.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for ingredient in current_recipe.inputs:
		var display: ItemWithCount = ITEM_WITH_COUNT.instantiate()
		display.item = ingredient.item
		display.required = ingredient.amount
		display.count = _get_inventory_count(ingredient.item)
		items_in_inventory.add_child(display)
		_ingredient_displays.append(display)


func update_inventory() -> void:
	for display in _ingredient_displays:
		display.count = _get_inventory_count(display.item)


func update_completion(progress: int, total: int) -> void:
	if progress < 0:
		completion_label.text = "---"
	else:
		completion_label.text = "%d / %d" % [progress, total]


func _on_selected_recipe() -> void:
	_picker = RECIPE_PICKER.instantiate()
	_picker.recipes = recipes
	_picker.recipe_selected.connect(_on_recipe_selected_from_picker)
	interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
		_picker,
		self,
	)


func _on_recipe_selected_from_picker(r: ItemRecipe) -> void:
	_set_recipe(r)
	generate_ui()
	_picker.close_self()
	_picker = null


func _get_recipe() -> ItemRecipe:
	return null


func _set_recipe(_r: ItemRecipe) -> void:
	pass


func _get_inventory_count(_item: FactoryItemInfo) -> int:
	return 0
