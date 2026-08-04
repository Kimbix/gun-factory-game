class_name ItemRecipe
extends Resource

@export var display_name: String = ""
@export var icon: Texture2D
@export var inputs: Array[RecipeIngredient]
@export var outputs: Array[RecipeIngredient]
@export var machine: GridComponentInfo
@export var craft_time: int = 15
