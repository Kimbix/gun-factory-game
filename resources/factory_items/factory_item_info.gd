class_name FactoryItemInfo
extends Resource

@export var name: StringName = &""
@export var texture: Texture2D

var grid_size: Vector2:
	get():
		if texture == null:
			return Vector2.ZERO
		return texture.get_size() / PlayerGrid.GRID_TEXTURE_SIZE
