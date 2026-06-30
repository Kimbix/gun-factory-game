class_name Room
extends Node2D

@export var room_id: StringName = &""
@export var floor_layer: int = 0
@export var wall_layer: int = 1


func get_tilemap() -> TileMap:
	for child in get_children():
		var tm := child as TileMap
		if tm != null:
			return tm
	return null


func get_used_tile_rect() -> Rect2i:
	var tm := get_tilemap()
	if tm == null:
		return Rect2i()
	return tm.get_used_rect()


func get_connection_points_global() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for child in get_children():
		var m := child as Marker2D
		if m == null:
			continue
		out.append(Vector2i(m.global_position))
	return out
