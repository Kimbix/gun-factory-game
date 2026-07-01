class_name Room
extends Node2D

@export var room_id: StringName = &""


func get_floor_layer() -> TileMapLayer:
	for child in get_children():
		var tml := child as TileMapLayer
		if tml != null and tml.name == &"FloorLayer":
			return tml
	return null


func get_wall_layer() -> TileMapLayer:
	for child in get_children():
		var tml := child as TileMapLayer
		if tml != null and tml.name == &"WallLayer":
			return tml
	return null


func get_used_tile_rect() -> Rect2i:
	return get_combined_used_rect()


func get_combined_used_rect() -> Rect2i:
	var min_x := 0
	var min_y := 0
	var max_x := -1
	var max_y := -1
	var found := false
	for layer in [get_floor_layer(), get_wall_layer()]:
		if layer == null:
			continue
		for c in layer.get_used_cells():
			if not found:
				min_x = c.x
				min_y = c.y
				max_x = c.x
				max_y = c.y
				found = true
			else:
				if c.x < min_x: min_x = c.x
				if c.y < min_y: min_y = c.y
				if c.x > max_x: max_x = c.x
				if c.y > max_y: max_y = c.y
	if not found:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func get_connection_points_local() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for child in get_children():
		var m := child as Marker2D
		if m == null:
			continue
		out.append(Vector2i(m.position))
	return out
