class_name FactoryItemInfo
extends Resource

@export var name: StringName = &""
@export var texture: Texture2D

var grid_size: Vector2:
	get():
		return texture.get_size() / PlayerGrid.GRID_TEXTURE_SIZE
