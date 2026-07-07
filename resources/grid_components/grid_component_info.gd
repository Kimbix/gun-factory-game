class_name GridComponentInfo
extends Resource

@export var name: StringName = &""
@export var display_name: StringName = &""
@export var texture: Texture2D = null
@export var dimensions: Vector2i = Vector2i.ZERO
@export var behaviour: Script = null
@export var color: Color = Color.WHITE
@export var ports: Array[Port] = []
