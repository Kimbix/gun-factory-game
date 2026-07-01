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
	var floor := get_floor_layer()
	if floor == null:
		return Rect2i()
	return floor.get_used_rect()


func get_connection_points_global() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for child in get_children():
		var m := child as Marker2D
		if m == null:
			continue
		out.append(Vector2i(m.global_position))
	return out
