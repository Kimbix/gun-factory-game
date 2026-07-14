class_name AmmoAssemblerInterface
extends InterfaceWindow

const ITEM_BUTTON := preload("uid://cq5f74b5ddssl")
const RECIPE_PICKER := preload("uid://0xiqunpp8bx8")

@export var close_button: Button
@export var selected_recipe: Button
@export var items_in_inventory: HBoxContainer
@export var completion_label: Label

var recipes: BaseRecipeCatalogue
var ammo_assembler: AmmoAssembler:
	get():
		return ammo_assembler
	set(v):
		ammo_assembler = v
		generate_ui()
var _picker: RecipePickerInterface


func _ready() -> void:
	close_button.pressed.connect(close_self)
	selected_recipe.pressed.connect(_on_selected_recipe)


func generate_ui() -> void:
	for child in items_in_inventory.get_children():
		child.queue_free()

	if ammo_assembler == null or ammo_assembler.recipe == null:
		selected_recipe.text = "?"
		selected_recipe.icon = null
		selected_recipe.expand_icon = true
		var label := Label.new()
		label.text = "No Recipe Selected"
		items_in_inventory.add_child(label)
		return

	selected_recipe.text = ""
	selected_recipe.icon = ammo_assembler.recipe.icon
	selected_recipe.expand_icon = true
	selected_recipe.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for ingredient in ammo_assembler.recipe.inputs:
		var button: ItemButton = ITEM_BUTTON.instantiate()
		button.item = ingredient.item
		items_in_inventory.add_child(button)


func update_completion(value: float) -> void:
	if value < 0:
		completion_label.text = "---"
	else:
		completion_label.text = "%d%%" % value


func _on_selected_recipe() -> void:
	_picker = RECIPE_PICKER.instantiate()
	_picker.recipes = recipes
	_picker.recipe_selected.connect(_on_recipe_selected_from_picker)
	InterfaceSupervisor.instance.open_interface(
		InterfaceSupervisor.InterfaceType.FACTORY_BUILDING, _picker, self
	)


func _on_recipe_selected_from_picker(r: ItemRecipe) -> void:
	ammo_assembler.set_recipe(r)
	generate_ui()
	_picker.close_self()
	_picker = null
