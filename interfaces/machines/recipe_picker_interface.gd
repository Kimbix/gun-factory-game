class_name RecipePickerInterface
extends InterfaceWindow

signal recipe_selected(r: ItemRecipe)

@export var close_button: Button
@export var recipe_grid: GridContainer
@export var recipes: BaseRecipeCatalogue


func _ready() -> void:
	close_button.pressed.connect(close_self)

	for r: ItemRecipe in recipes.recipes:
		var button := Button.new()
		var texture := TextureRect.new()
		texture.texture = r.icon
		texture.set_anchors_preset(Control.PRESET_FULL_RECT)
		texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.custom_minimum_size = Vector2.ONE * 32
		var tooltip_str := "%s\n%s ticks" % [r.display_name, r.craft_time]
		button.mouse_entered.connect(TooltipCanvas.show_tooltip.bind(tooltip_str))
		button.mouse_exited.connect(TooltipCanvas.hide_tooltip)
		button.add_child(texture)
		button.pressed.connect(_on_recipe_pressed.bind(r))
		recipe_grid.add_child(button)


func _on_recipe_pressed(r: ItemRecipe) -> void:
	recipe_selected.emit(r)
