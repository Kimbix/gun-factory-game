class_name MetalProcessorInterface
extends PanelContainer

signal recipe_selected(r: ItemRecipe)

@onready var recipes: RecipeCatalogue = load("res://resources/recipes/metal_processor_recipes.tres")
@onready var selected_recipe_icon: TextureRect = $SelectedRecipe
@onready var pickable_recipes: GridContainer = $PickableRecipes
@onready var close_button: Button = $CloseButton


func _ready() -> void:
	close_button.pressed.connect(self.queue_free)
	for r: ItemRecipe in recipes.recipes:
		var button := Button.new()
		var text := TextureRect.new()
		text.texture = r.icon
		text.set_anchors_preset(Control.PRESET_FULL_RECT)
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.custom_minimum_size = Vector2.ONE * 32
		button.tooltip_text = r.display_name
		button.add_child(text)
		button.pressed.connect(_selected_recipe.bind(r))
		pickable_recipes.add_child(button)


func change_recipe(r: ItemRecipe) -> void:
	if r != null:
		selected_recipe_icon.texture = r.icon


func _selected_recipe(r: ItemRecipe) -> void:
	print(r)
	recipe_selected.emit(r)
