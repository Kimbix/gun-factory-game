class_name Minimap
extends Control

const META_ATTRIBUTE := &"minimap_texture"
const GROUP_NAME := &"minimap_viewable"

var world: GameDirector
## How many units of map are a unit of minimap
## An object in (100, 100) would show in the minimap as (10, 10)
## with a scale of 10.0
var zoom_scale: float = 10.0
var minimap_position: Vector2 = Vector2.ZERO


func generate() -> void:
	var minimap_size: Vector2 = get_rect().size
	minimap_position = -(minimap_size / 2.0) # Offset so 0,0 is the center

	for n: Node in get_tree().get_nodes_in_group(GROUP_NAME):
		if not n.has_meta(META_ATTRIBUTE):
			continue
		var minimap_indicator := _create_indicator_from_node(n)
		self.add_child(minimap_indicator)


func _create_indicator_from_node(n: Node2D) -> TextureRect:
	var minimap_indicator := TextureRect.new()
	var texture: Texture2D = n.get_meta(META_ATTRIBUTE)
	var indicator_size := Vector2.ONE * 16
	var object_scaled_position := n.position / zoom_scale
	var final_position := ((object_scaled_position - minimap_position) - indicator_size * .5)
	minimap_indicator.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	minimap_indicator.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	minimap_indicator.size = indicator_size
	minimap_indicator.texture = texture
	minimap_indicator.position = final_position
	return minimap_indicator
