class_name ConveyorSplitter
extends FactoryComponent

const ITEM_SPEED := 0.05

var _entering: Array[FactoryItem] = []
var _lanes: Array = [[], [], []]
var _next_lane: int = 0
var _cached_in_port: Port
var _cached_out_ports: Array[Port]
var _last_rotation: FactoryBuilding.Rotation


func tick() -> void:
	if not _refresh_cache():
		return

	var enter_dir := -Vector2(_cached_in_port.facing)
	var center := Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * 0.5,
	)

	_entering.sort_custom(func(a: FactoryItem, b: FactoryItem) -> bool:
		return _progress_in(a, enter_dir) < _progress_in(b, enter_dir)
	)

	for i: int in range(_entering.size() - 1, -1, -1):
		var cur := _entering[i]
		var ahead: FactoryItem = null
		if i + 1 < _entering.size():
			ahead = _entering[i + 1]

		if not _is_centered_on(cur, enter_dir):
			cur.position = _step_to_center(cur, enter_dir)
			continue

		var next_pos := cur.position + enter_dir * ITEM_SPEED

		if _would_collide_in(next_pos, ahead, enter_dir):
			continue

		if _passed_point(next_pos + cur.rect.size * 0.5, center, enter_dir):
			_entering.remove_at(i)
			_lanes[_next_lane].append(cur)
			_next_lane = (_next_lane + 1) % 3
		else:
			cur.position = next_pos

	for idx: int in 3:
		var exit_dir := Vector2(_cached_out_ports[idx].facing)
		var port := _cached_out_ports[idx]

		var lane: Array = _lanes[idx]
		lane.sort_custom(func(a: FactoryItem, b: FactoryItem) -> bool:
			return _progress_in(a, exit_dir) < _progress_in(b, exit_dir)
		)
		for i: int in range(lane.size() - 1, -1, -1):
			var cur: FactoryItem = lane[i] as FactoryItem
			var ahead: FactoryItem = null
			if i + 1 < lane.size():
				ahead = lane[i + 1] as FactoryItem

			var next_pos := cur.position + exit_dir * ITEM_SPEED

			if _would_collide_in(next_pos, ahead, exit_dir):
				continue

			if _dist_to_exit_in(cur, exit_dir) < cur.rect.size.x:
				var build := grid.get_building(position + port.position + port.facing)
				if build != null and not build.behaviour.can_accept(cur):
					continue

			if _will_exit_in(next_pos, cur, exit_dir):
				var build := grid.get_building(position + port.position + port.facing)
				if build != null:
					lane.remove_at(i)
					build.receive_item(cur)
				continue

			cur.position = next_pos


func can_accept(item: FactoryItem) -> bool:
	if not _refresh_cache():
		return false

	var enter_dir := -Vector2(_cached_in_port.facing)
	for existing: FactoryItem in _entering:
		if _calc_gap_in(item.position, existing, enter_dir) < item.rect.size.x:
			return false

	for idx: int in 3:
		var lane: Array = _lanes[idx]
		if lane.is_empty():
			return true
		var last: FactoryItem = lane[-1] as FactoryItem
		var exit_dir := Vector2(_cached_out_ports[idx].facing)
		if _dist_to_exit_in(last, exit_dir) >= last.rect.size.x:
			return true

	return false


func receive_item(item: FactoryItem) -> void:
	_entering.append(item)


func _refresh_cache() -> bool:
	if _cached_in_port != null and _cached_out_ports.size() == 3 and _last_rotation == rotation:
		return true
	var all := grid.get_building_ports(position)
	var in_ports := all.filter(Port.input_mode_filter)
	if in_ports.is_empty():
		return false
	_cached_in_port = in_ports[0]
	_cached_out_ports = all.filter(Port.output_mode_filter)
	if _cached_out_ports.size() != 3:
		return false
	_last_rotation = rotation
	return true


func _is_centered_on(cur: FactoryItem, dir: Vector2) -> bool:
	if dir.x != 0:
		return abs(cur.position.y + cur.rect.size.y * 0.5 - rect.position.y - rect.size.y * 0.5) < 0.005
	else:
		return abs(cur.position.x + cur.rect.size.x * 0.5 - rect.position.x - rect.size.x * 0.5) < 0.005


func _step_to_center(cur: FactoryItem, dir: Vector2) -> Vector2:
	if dir.x != 0:
		var cy := rect.position.y + rect.size.y * 0.5 - cur.rect.size.y * 0.5
		var diff := cy - cur.position.y
		if abs(diff) <= ITEM_SPEED:
			return Vector2(cur.position.x, cy)
		return Vector2(cur.position.x, cur.position.y + sign(diff) * ITEM_SPEED)
	else:
		var cx := rect.position.x + rect.size.x * 0.5 - cur.rect.size.x * 0.5
		var diff := cx - cur.position.x
		if abs(diff) <= ITEM_SPEED:
			return Vector2(cx, cur.position.y)
		return Vector2(cur.position.x + sign(diff) * ITEM_SPEED, cur.position.y)


func _passed_point(p: Vector2, target: Vector2, dir: Vector2) -> bool:
	if dir.x > 0:
		return p.x >= target.x
	elif dir.x < 0:
		return p.x <= target.x
	elif dir.y > 0:
		return p.y >= target.y
	else:
		return p.y <= target.y


func _would_collide_in(next_pos: Vector2, ahead: FactoryItem, dir: Vector2) -> bool:
	if ahead == null:
		return false
	return _calc_gap_in(next_pos, ahead, dir) < ahead.rect.size.x


func _progress_in(item: FactoryItem, dir: Vector2) -> float:
	if dir.x > 0:
		return item.position.x
	elif dir.x < 0:
		return -item.position.x
	elif dir.y > 0:
		return item.position.y
	else:
		return -item.position.y


func _calc_gap_in(next_pos: Vector2, ahead: FactoryItem, dir: Vector2) -> float:
	if dir.x > 0:
		return ahead.position.x - next_pos.x
	elif dir.x < 0:
		return next_pos.x - ahead.position.x
	elif dir.y > 0:
		return ahead.position.y - next_pos.y
	else:
		return next_pos.y - ahead.position.y


func _dist_to_exit_in(cur: FactoryItem, dir: Vector2) -> float:
	if dir.x > 0:
		return rect.position.x + rect.size.x - (cur.position.x + cur.rect.size.x)
	elif dir.x < 0:
		return cur.position.x - rect.position.x
	elif dir.y > 0:
		return rect.position.y + rect.size.y - (cur.position.y + cur.rect.size.y)
	else:
		return cur.position.y - rect.position.y


func _will_exit_in(next_pos: Vector2, cur: FactoryItem, dir: Vector2) -> bool:
	var c := next_pos + cur.rect.size * 0.5
	if dir.x > 0:
		return c.x >= rect.position.x + rect.size.x
	elif dir.x < 0:
		return c.x <= rect.position.x
	elif dir.y > 0:
		return c.y >= rect.position.y + rect.size.y
	else:
		return c.y <= rect.position.y
