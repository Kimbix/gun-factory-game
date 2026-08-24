class_name MinimapPositioner
extends Node

const DEFAULT_MINIMAP_TEXTURE := preload("uid://big57t701jgrd")

@export var minimap_texture: Texture2D


func _ready() -> void:
	var texture: Texture2D = DEFAULT_MINIMAP_TEXTURE
	if minimap_texture != null:
		texture = minimap_texture
	get_parent().set_meta(Minimap.META_ATTRIBUTE, texture)
	get_parent().add_to_group(Minimap.GROUP_NAME)
	self.queue_free()
