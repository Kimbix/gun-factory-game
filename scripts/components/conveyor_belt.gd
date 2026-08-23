class_name ConveyorBelt
extends FactoryComponent

const ITEM_SPEED := 0.05

var items: Array[FactoryItem] = []

var _cached_move_dir: Vector2
var _cached_is_horizontal: bool
var _cached_entry_edge: float
var _cached_exit_edge: float


func setup() -> void:
	building.rotated.connect(_cache_rotation)
	_cache_rotation()


func free_resources() -> void:
	var g := grid
	if g != null:
		for item: FactoryItem in items:
			g.destroy_item(item)
	items.clear()


func _cache_rotation() -> void:
	_cached_is_horizontal = rotation == FactoryBuilding.Rotation.NORMAL \
			or rotation == FactoryBuilding.Rotation.FLIPPED
	match rotation:
		FactoryBuilding.Rotation.NORMAL:
			_cached_move_dir = Vector2.RIGHT
			_cached_entry_edge = rect.position.x
			_cached_exit_edge = rect.position.x + rect.size.x
		FactoryBuilding.Rotation.FLIPPED:
			_cached_move_dir = Vector2.LEFT
			_cached_entry_edge = rect.position.x + rect.size.x
			_cached_exit_edge = rect.position.x
		FactoryBuilding.Rotation.CLOCKWISE:
			_cached_move_dir = Vector2.DOWN
			_cached_entry_edge = rect.position.y
			_cached_exit_edge = rect.position.y + rect.size.y
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			_cached_move_dir = Vector2.UP
			_cached_entry_edge = rect.position.y + rect.size.y
			_cached_exit_edge = rect.position.y


func tick() -> void:
	var next_build := _next_building()
	for i: int in range(items.size() - 1, -1, -1):
		var cur := items[i]
		var ahead := items[i + 1] if i + 1 < items.size() else null

		if ahead == null and next_build != null \
				and next_build.behaviour is ConveyorBelt \
				and next_build.rotation == rotation \
				and next_build.behaviour.items.size() > 0:
			ahead = next_build.behaviour.items[0]

		if not _is_centered(cur):
			cur.position = _step_toward_center(cur)
			continue

		var next_pos := cur.position + _cached_move_dir * ITEM_SPEED

		if _would_collide(next_pos, ahead, cur.rect.size):
			continue

		if _will_exit(next_pos, cur):
			if next_build != null:
				var from := position + _get_available_out_port().position
				if next_build.behaviour.can_accept(cur, from):
					items.remove_at(i)
					next_build.receive_item(cur)
					continue
			cur.position = _clamp_to_exit(cur)
			continue

		cur.position = next_pos


func can_accept(item: FactoryItem, from: Vector2i) -> bool:
	if not _has_input_port_facing(from):
		return false
	for existing: FactoryItem in items:
		if _calc_gap(item.position, existing) < item.rect.size.x:
			return false
	return true


func receive_item(item: FactoryItem) -> void:
	items.append(item)
	items.sort_custom(
		func(a: FactoryItem, b: FactoryItem) -> bool:
			return _progress(a) < _progress(b)
	)


func _is_centered(cur: FactoryItem) -> bool:
	var dist: float
	if _cached_is_horizontal:
		dist = abs(cur.position.y + cur.rect.size.y * 0.5 - rect.position.y - rect.size.y * 0.5)
	else:
		dist = abs(cur.position.x + cur.rect.size.x * 0.5 - rect.position.x - rect.size.x * 0.5)
	return dist < 0.005


func _step_toward_center(cur: FactoryItem) -> Vector2:
	if _cached_is_horizontal:
		var center_y := rect.position.y + rect.size.y * 0.5 - cur.rect.size.y * 0.5
		var diff := center_y - cur.position.y
		if abs(diff) <= ITEM_SPEED:
			return Vector2(cur.position.x, center_y)
		return Vector2(cur.position.x, cur.position.y + sign(diff) * ITEM_SPEED)
	else:
		var center_x := rect.position.x + rect.size.x * 0.5 - cur.rect.size.x * 0.5
		var diff := center_x - cur.position.x
		if abs(diff) <= ITEM_SPEED:
			return Vector2(center_x, cur.position.y)
		return Vector2(cur.position.x + sign(diff) * ITEM_SPEED, cur.position.y)


func _dist_to_exit(cur: FactoryItem) -> float:
	if _cached_exit_edge > _cached_entry_edge:
		if _cached_is_horizontal:
			return _cached_exit_edge - (cur.position.x + cur.rect.size.x)
		else:
			return _cached_exit_edge - (cur.position.y + cur.rect.size.y)
	else:
		if _cached_is_horizontal:
			return cur.position.x - _cached_exit_edge
		else:
			return cur.position.y - _cached_exit_edge


func _clamp_to_exit(cur: FactoryItem) -> Vector2:
	var pos := cur.position
	if _cached_exit_edge > _cached_entry_edge:
		if _cached_is_horizontal:
			pos.x = _cached_exit_edge - cur.rect.size.x
		else:
			pos.y = _cached_exit_edge - cur.rect.size.y
	else:
		if _cached_is_horizontal:
			pos.x = _cached_exit_edge
		else:
			pos.y = _cached_exit_edge
	return pos


func _next_building() -> FactoryBuilding:
	var p := _get_available_out_port()
	if p == null:
		return null
	var g := grid
	if g == null:
		return null
	return g.get_building(position + p.position + p.facing)


func _progress(item: FactoryItem) -> float:
	if _cached_exit_edge > _cached_entry_edge:
		return item.position.x if _cached_is_horizontal else item.position.y
	else:
		return -item.position.x if _cached_is_horizontal else -item.position.y


func _will_exit(next_pos: Vector2, cur: FactoryItem) -> bool:
	if _cached_exit_edge > _cached_entry_edge:
		if _cached_is_horizontal:
			return next_pos.x + cur.rect.size.x >= _cached_exit_edge
		else:
			return next_pos.y + cur.rect.size.y >= _cached_exit_edge
	else:
		if _cached_is_horizontal:
			return next_pos.x <= _cached_exit_edge
		else:
			return next_pos.y <= _cached_exit_edge


func _would_collide(next_pos: Vector2, ahead: FactoryItem, item_size: Vector2) -> bool:
	if ahead == null:
		return false
	return _calc_gap(next_pos, ahead) < item_size.x


func _calc_gap(next_pos: Vector2, ahead: FactoryItem) -> float:
	if _cached_exit_edge > _cached_entry_edge:
		if _cached_is_horizontal:
			return ahead.position.x - next_pos.x
		else:
			return ahead.position.y - next_pos.y
	else:
		if _cached_is_horizontal:
			return next_pos.x - ahead.position.x
		else:
			return next_pos.y - ahead.position.y
