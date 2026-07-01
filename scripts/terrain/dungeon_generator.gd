class_name DungeonGenerator
extends Node2D

const TILE_SIZE := 16
const MARGIN := 4 * TILE_SIZE
const MAX_TILE_LOOP := 100_000

const XFORM_IDENTITY := 0
const XFORM_ROTATE_90 := 1
const XFORM_ROTATE_270 := 2
const XFORM_FLIP_H := 3
const XFORM_FLIP_V := 4

const XFORM_NAMES := ["IDENTITY", "ROTATE_90", "ROTATE_270", "FLIP_H", "FLIP_V"]

@export var room_scenes: Array[PackedScene] = []
@export var room_count: int = 5
@export var extra_connections: int = 2
@export var corridor_width: int = 2
@export var min_room_size: Vector2i = Vector2i(4, 4)
@export var max_room_size: Vector2i = Vector2i(10, 8)
@export var floor_layer: TileMapLayer
@export var wall_layer: TileMapLayer
@export var player: Node2D


func _ready() -> void:
	print("DungeonGenerator._ready() called")
	generate()


func generate() -> void:
	if floor_layer == null or wall_layer == null:
		print("DungeonGenerator: floor_layer or wall_layer is null")
		return
	floor_layer.clear()
	wall_layer.clear()

	var rooms: Array[Dictionary] = []
	print("DungeonGenerator: generating %d rooms (scenes: %s)" % [room_count, "yes" if not room_scenes.is_empty() else "no"])

	for i in room_count:
		var placed := false
		for attempt in 50:
			var room: Node2D
			var origin: Vector2i
			var rect: Rect2i
			var conns: Array[Vector2i]
			var is_scene_room := false
			var xform := XFORM_IDENTITY
			var room_w := 0
			var room_h := 0
			var try_scene: bool = not room_scenes.is_empty()

			if try_scene:
				var scene: PackedScene = room_scenes.pick_random()
				room = scene.instantiate()
				origin = Vector2i(randi_range(-50, 50) * TILE_SIZE, randi_range(-50, 50) * TILE_SIZE)
				room.position = Vector2(origin)
				var used_rect: Rect2i
				if room.has_method(&"get_used_tile_rect"):
					used_rect = room.get_used_tile_rect()
				if used_rect != Rect2i():
					xform = randi_range(XFORM_IDENTITY, XFORM_FLIP_V)
					room_w = used_rect.size.x
					room_h = used_rect.size.y
					var xformed_size := _xform_size(room_w, room_h, xform)
					rect = Rect2i(origin, Vector2i(xformed_size.x, xformed_size.y) * TILE_SIZE)
					conns = _xform_connections(room, origin, room_w, room_h, xform)
					is_scene_room = true
				else:
					try_scene = false

			if not try_scene:
				if room != null:
					room.queue_free()
					room = null
				var w: int = randi_range(min_room_size.x, max_room_size.x)
				var h: int = randi_range(min_room_size.y, max_room_size.y)
				origin = Vector2i(randi_range(-50, 50) * TILE_SIZE, randi_range(-50, 50) * TILE_SIZE)
				rect = Rect2i(origin, Vector2i(w, h) * TILE_SIZE)
				conns = []
				var conn_count: int = randi_range(1, 3)
				for j in range(conn_count):
					conns.append(_random_connection_on_wall(origin, w, h))

			if _overlaps(rect, rooms):
				if attempt == 0:
					print("  room %d: overlap on first attempt, may get stuck" % i)
				if room != null:
					room.queue_free()
				continue

			var entry: Dictionary = {
				origin = origin,
				rect = rect,
				connections = conns,
				node = room,
			}
			if is_scene_room:
				entry.xform = xform
			rooms.append(entry)
			placed = true
			var label := "scene" if is_scene_room else "procedural"
			print("  room %d placed (%s, origin=%s, size=%s)" % [i, label, origin, rect.size])
			break

		if not placed:
			print("  room %d: FAILED to place after 50 attempts" % i)

	print("DungeonGenerator: placed %d/%d rooms" % [rooms.size(), room_count])

	for idx in range(rooms.size()):
		var r := rooms[idx]
		print("  copying tiles for room %d/%d" % [idx + 1, rooms.size()])
		if r.node != null:
			_copy_room_tiles(r)
		else:
			_build_room_tiles(r)
	print("  tile copying done")

	print("DungeonGenerator: connecting rooms...")
	_connect_rooms(rooms)
	print("DungeonGenerator: connections done")

	if player != null and not rooms.is_empty():
		var center: Vector2i = rooms[0].rect.get_center()
		player.position = Vector2(center)
		print("DungeonGenerator: player positioned at %s" % center)


func _copy_room_tiles(r: Dictionary) -> void:
	var room_node: Node2D = r.node
	if room_node == null:
		return
	var xform: int = r.get("xform", XFORM_IDENTITY)
	var origin: Vector2i = r.origin
	var min_corner := Vector2i.ZERO
	var room_w := 0
	var room_h := 0
	var src_floor: TileMapLayer
	var src_wall: TileMapLayer
	if room_node.has_method(&"get_floor_layer"):
		src_floor = room_node.call(&"get_floor_layer")
	if room_node.has_method(&"get_wall_layer"):
		src_wall = room_node.call(&"get_wall_layer")
	var min_x := 0
	var min_y := 0
	var max_x := -1
	var max_y := -1
	var found := false
	for layer in [src_floor, src_wall]:
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
		return
	min_corner = Vector2i(min_x, min_y)
	room_w = max_x - min_x + 1
	room_h = max_y - min_y + 1
	print("    room bounds: origin=%s, %dx%d" % [min_corner, room_w, room_h])
	if room_w > MAX_TILE_LOOP or room_h > MAX_TILE_LOOP:
		print("  WARNING: room too large (%d x %d), skipping" % [room_w, room_h])
		return
	if src_floor != null:
		var cells := src_floor.get_used_cells()
		print("    floor: %d tiles" % cells.size())
		_copy_layer_tiles(src_floor, floor_layer, origin, xform, min_corner, room_w, room_h)
	if src_wall != null:
		var cells := src_wall.get_used_cells()
		print("    wall: %d tiles" % cells.size())
		_copy_layer_tiles(src_wall, wall_layer, origin, xform, min_corner, room_w, room_h)
	var box_origin := Vector2i(min_corner * TILE_SIZE)
	for child in room_node.get_children():
		if child is TileMapLayer or child is Marker2D:
			continue
		var child2d := child as Node2D
		if child2d == null:
			continue
		child2d.owner = null
		var offset := Vector2i(child2d.position) - box_origin
		var xformed := _xform_point(offset.x, offset.y, room_w, room_h, xform)
		var world_pos := Vector2(origin) + Vector2(xformed)
		child2d.reparent(self)
		child2d.position = world_pos


func _copy_layer_tiles(src: TileMapLayer, dst: TileMapLayer, origin: Vector2i, xf: int, min_corner: Vector2i, w: int, h: int) -> void:
	var cells := src.get_used_cells()
	if cells.is_empty():
		return
	var origin_cell := _pixel_to_cell(origin)
	for c in cells:
		var lx := c.x - min_corner.x
		var ly := c.y - min_corner.y
		var src_id: int = src.get_cell_source_id(c)
		if src_id == -1:
			continue
		var atlas: Vector2i = src.get_cell_atlas_coords(c)
		var alt: int = src.get_cell_alternative_tile(c)
		var dst_local := _xform_cell(lx, ly, w, h, xf)
		var dst_cell := origin_cell + dst_local
		dst.set_cell(dst_cell, src_id, atlas, alt)


func _pixel_to_cell(p: Vector2i) -> Vector2i:
	return Vector2i(floori(float(p.x) / TILE_SIZE), floori(float(p.y) / TILE_SIZE))


func _xform_size(w: int, h: int, xf: int) -> Vector2i:
	match xf:
		XFORM_ROTATE_90, XFORM_ROTATE_270:
			return Vector2i(h, w)
		_:
			return Vector2i(w, h)


func _xform_cell(lx: int, ly: int, w: int, h: int, xf: int) -> Vector2i:
	match xf:
		XFORM_IDENTITY:
			return Vector2i(lx, ly)
		XFORM_ROTATE_90:
			return Vector2i(ly, w - 1 - lx)
		XFORM_ROTATE_270:
			return Vector2i(h - 1 - ly, lx)
		XFORM_FLIP_H:
			return Vector2i(w - 1 - lx, ly)
		XFORM_FLIP_V:
			return Vector2i(lx, h - 1 - ly)
	return Vector2i(lx, ly)


func _xform_point(px: int, py: int, w: int, h: int, xf: int) -> Vector2i:
	var tile_w := w * TILE_SIZE
	var tile_h := h * TILE_SIZE
	match xf:
		XFORM_IDENTITY:
			return Vector2i(px, py)
		XFORM_ROTATE_90:
			return Vector2i(py, tile_w - px)
		XFORM_ROTATE_270:
			return Vector2i(tile_h - py, px)
		XFORM_FLIP_H:
			return Vector2i(tile_w - px, py)
		XFORM_FLIP_V:
			return Vector2i(px, tile_h - py)
	return Vector2i(px, py)


func _xform_connections(room: Node2D, origin: Vector2i, w: int, h: int, xf: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if not room.has_method(&"get_connection_points_local"):
		return out
	var points: Array[Vector2i] = room.get_connection_points_local()
	for p in points:
		var xformed := _xform_point(p.x, p.y, w, h, xf)
		out.append(origin + xformed)
	return out


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
				wall_layer.set_cell(cell, 0, Vector2i(1, 0))
			else:
				floor_layer.set_cell(cell, 0, Vector2i(0, 0))


func _connect_rooms(rooms: Array[Dictionary]) -> void:
	if rooms.size() < 2:
		print("DungeonGenerator: <2 rooms, no corridors to carve")
		return
	print("DungeonGenerator: connecting %d rooms (extra_connections=%d)" % [rooms.size(), extra_connections])

	var visited: Array[int] = [0]
	var unvisited: Array[int] = []
	for i in range(1, rooms.size()):
		unvisited.append(i)

	var conn_idx := 0
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

		print("  corridor %d: room %d -> %d" % [conn_idx, best_visited, best_unvisited])
		_carve_connection(rooms[best_visited], rooms[best_unvisited])
		visited.append(best_unvisited)
		unvisited.erase(best_unvisited)
		conn_idx += 1

	for i in extra_connections:
		var a: int = randi_range(0, rooms.size() - 1)
		var b: int = randi_range(0, rooms.size() - 1)
		if a != b:
			print("  extra corridor: room %d -> %d" % [a, b])
			_carve_connection(rooms[a], rooms[b])


func _carve_connection(a: Dictionary, b: Dictionary) -> void:
	var ap := _pick_point(a)
	var bp := _pick_point(b)
	print("    points: %s -> %s" % [ap, bp])
	_carve_l_path(ap, bp)


func _pick_point(r: Dictionary) -> Vector2i:
	var conns: Array = r.get("connections", [])
	if not conns.is_empty():
		return conns.pick_random()
	return Vector2i(r.rect.get_center())


func _snap_to_tile(p: Vector2i) -> Vector2i:
	return Vector2i(floori(float(p.x) / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2,
					floori(float(p.y) / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2)


func _carve_l_path(from: Vector2i, to: Vector2i) -> void:
	var sf := _snap_to_tile(from)
	var st := _snap_to_tile(to)
	var mid := Vector2i(st.x, sf.y)
	var steps_a: Array[Vector2i] = _carve_straight(sf, mid)
	var steps_b: Array[Vector2i] = _carve_straight(mid, st)
	var corner_pixels := steps_a + steps_b
	for c in corner_pixels:
		for dx in [-1, 1]:
			for dy in [-1, 1]:
				var diag := c + Vector2i(dx, dy)
				if floor_layer.get_cell_source_id(diag) == -1 and wall_layer.get_cell_source_id(diag) == -1:
					wall_layer.set_cell(diag, 0, Vector2i(1, 0))


func _carve_straight(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if from == to:
		return []
	var half: int = corridor_width / 2
	var dx: int = signi(to.x - from.x)
	var dy: int = signi(to.y - from.y)
	var perp := Vector2i(0, 1) if dx != 0 else Vector2i(1, 0)
	var pos := from
	var step_cells: Array[Vector2i] = []
	while pos != to:
		for w in range(-half, corridor_width - half):
			var cell := _pixel_to_cell(pos + perp * w * TILE_SIZE)
			if wall_layer.get_cell_source_id(cell) != -1:
				wall_layer.set_cell(cell, -1)
			if floor_layer.get_cell_source_id(cell) == -1:
				floor_layer.set_cell(cell, 0, Vector2i(0, 0))
		step_cells.append(_pixel_to_cell(pos))
		if pos.x != to.x:
			pos.x += dx * TILE_SIZE
		if pos.y != to.y:
			pos.y += dy * TILE_SIZE
		if dx > 0 and pos.x > to.x: pos.x = to.x
		if dx < 0 and pos.x < to.x: pos.x = to.x
		if dy > 0 and pos.y > to.y: pos.y = to.y
		if dy < 0 and pos.y < to.y: pos.y = to.y
	for w in range(-half, corridor_width - half):
		var cell := _pixel_to_cell(to + perp * w * TILE_SIZE)
		if wall_layer.get_cell_source_id(cell) != -1:
			wall_layer.set_cell(cell, -1)
		if floor_layer.get_cell_source_id(cell) == -1:
			floor_layer.set_cell(cell, 0, Vector2i(0, 0))
	step_cells.append(_pixel_to_cell(to))
	for c in step_cells:
		for side in [-half - 1, corridor_width - half]:
			var wall_cell := c + _pixel_to_cell(perp * side * TILE_SIZE)
			if floor_layer.get_cell_source_id(wall_cell) == -1 and wall_layer.get_cell_source_id(wall_cell) == -1:
				wall_layer.set_cell(wall_cell, 0, Vector2i(1, 0))
	return step_cells
