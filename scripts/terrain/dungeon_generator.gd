class_name DungeonGenerator
extends Node2D

const TILE_SIZE := 16
const MARGIN := 4 * TILE_SIZE

@export var room_scenes: Array[PackedScene] = []
@export var room_count: int = 5
@export var extra_connections: int = 2
@export var corridor_width: int = 2
@export var min_room_size: Vector2i = Vector2i(4, 4)
@export var max_room_size: Vector2i = Vector2i(10, 8)
@export var tilemap: TileMap
@export var player: Node2D


func _ready() -> void:
	generate()


func generate() -> void:
	if tilemap == null:
		return
	tilemap.clear()

	var rooms: Array[Dictionary] = []

	for i in room_count:
		var placed := false
		for attempt in 50:
			var w: int = randi_range(min_room_size.x, max_room_size.x)
			var h: int = randi_range(min_room_size.y, max_room_size.y)
			var origin := Vector2i(randi_range(-50, 50) * TILE_SIZE, randi_range(-50, 50) * TILE_SIZE)
			var rect := Rect2i(origin, Vector2i(w, h) * TILE_SIZE)

			if _overlaps(rect, rooms):
				continue

			var conn_count: int = randi_range(1, 3)
			var conns: Array[Vector2i] = []
			for j in range(conn_count):
				var cp := _random_connection_on_wall(origin, w, h)
				conns.append(cp)

			rooms.append({
				origin = origin,
				rect = rect,
				connections = conns,
			})
			placed = true
			break

	for r in rooms:
		_build_room_tiles(r)

	_connect_rooms(rooms)

	if player != null and not rooms.is_empty():
		var center: Vector2i = rooms[0].rect.get_center()
		player.position = Vector2(center)


func _overlaps(rect: Rect2i, rooms: Array[Dictionary]) -> bool:
	var big := Rect2i(rect.position - Vector2i.ONE * MARGIN, rect.size + Vector2i.ONE * MARGIN * 2)
	for r in rooms:
		if big.intersects(r.rect):
			return true
	return false


func _random_connection_on_wall(origin: Vector2i, w: int, h: int) -> Vector2i:
	var side: int = randi_range(0, 3)
	match side:
		0:
			return origin + Vector2i(randi_range(1, w - 1) * TILE_SIZE, 0)
		1:
			return origin + Vector2i(randi_range(1, w - 1) * TILE_SIZE, h * TILE_SIZE)
		2:
			return origin + Vector2i(0, randi_range(1, h - 1) * TILE_SIZE)
		3:
			return origin + Vector2i(w * TILE_SIZE, randi_range(1, h - 1) * TILE_SIZE)
	return origin


func _build_room_tiles(r: Dictionary) -> void:
	var room_rect: Rect2i = r.rect
	var room_origin: Vector2i = r.origin
	var w: int = room_rect.size.x / TILE_SIZE
	var h: int = room_rect.size.y / TILE_SIZE
	var origin_cell := _pixel_to_cell(room_origin)

	for x in range(w):
		for y in range(h):
			var cell := origin_cell + Vector2i(x, y)
			var is_wall: bool = x == 0 or x == w - 1 or y == 0 or y == h - 1
			if is_wall:
				tilemap.set_cell(1, cell, 0, Vector2i(1, 0))
			else:
				tilemap.set_cell(0, cell, 0, Vector2i(0, 0))


func _pixel_to_cell(p: Vector2i) -> Vector2i:
	return Vector2i(floori(float(p.x) / TILE_SIZE), floori(float(p.y) / TILE_SIZE))


func _connect_rooms(rooms: Array[Dictionary]) -> void:
	if rooms.size() < 2:
		return

	var visited: Array[int] = [0]
	var unvisited: Array[int] = []
	for i in range(1, rooms.size()):
		unvisited.append(i)

	while not unvisited.is_empty():
		var best_dist: float = INF
		var best_visited: int = -1
		var best_unvisited: int = -1

		for v in visited:
			var rect_v: Rect2i = rooms[v].rect
			for u in unvisited:
				var rect_u: Rect2i = rooms[u].rect
				var d: float = rect_v.get_center().distance_squared_to(rect_u.get_center())
				if d < best_dist:
					best_dist = d
					best_visited = v
					best_unvisited = u

		if best_visited < 0 or best_unvisited < 0:
			break

		_carve_connection(rooms[best_visited], rooms[best_unvisited])
		visited.append(best_unvisited)
		unvisited.erase(best_unvisited)

	for i in extra_connections:
		var a: int = randi_range(0, rooms.size() - 1)
		var b: int = randi_range(0, rooms.size() - 1)
		if a != b:
			_carve_connection(rooms[a], rooms[b])


func _carve_connection(a: Dictionary, b: Dictionary) -> void:
	var ap := _pick_point(a)
	var bp := _pick_point(b)
	_carve_l_path(ap, bp)


func _pick_point(r: Dictionary) -> Vector2i:
	var conns: Array = r.get("connections", [])
	if not conns.is_empty():
		return conns.pick_random()
	return Vector2i(r.rect.get_center())


func _carve_l_path(from: Vector2i, to: Vector2i) -> void:
	var mid := Vector2i(to.x, from.y)
	_carve_straight(from, mid)
	_carve_straight(mid, to)


func _carve_straight(from: Vector2i, to: Vector2i) -> void:
	if from == to:
		return
	var half: int = corridor_width / 2
	var dx: int = signi(to.x - from.x)
	var dy: int = signi(to.y - from.y)
	var pos := from
	while pos != to:
		for w in range(-half, corridor_width - half):
			var cell := _pixel_to_cell(Vector2i(pos.x, pos.y + w))
			if tilemap.get_cell_source_id(1, cell) != -1:
				tilemap.set_cell(1, cell, -1)
			if tilemap.get_cell_source_id(0, cell) == -1:
				tilemap.set_cell(0, cell, 0, Vector2i(0, 0))
		if pos.x != to.x:
			pos.x += dx * TILE_SIZE
		if pos.y != to.y:
			pos.y += dy * TILE_SIZE
	for w in range(-half, corridor_width - half):
		var cell := _pixel_to_cell(Vector2i(to.x, to.y + w))
		if tilemap.get_cell_source_id(1, cell) != -1:
			tilemap.set_cell(1, cell, -1)
		if tilemap.get_cell_source_id(0, cell) == -1:
			tilemap.set_cell(0, cell, 0, Vector2i(0, 0))
