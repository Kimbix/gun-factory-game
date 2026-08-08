class_name ConveyorBelt
extends FactoryComponent

const ITEM_SPEED := 0.05

var items: Array[FactoryItem] = []


func free_resources() -> void:
	var g := grid
	if g != null:
		for item: FactoryItem in items:
			g.destroy_item(item)
	items.clear()


func tick() -> void:
	for i: int in range(items.size() - 1, -1, -1):
		var cur := items[i]
		var ahead := items[i + 1] if i + 1 < items.size() else null

		if not _is_centered(cur):
			cur.position = _step_toward_center(cur)
			continue

		var next_pos := cur.position + _move_dir() * ITEM_SPEED

		if _would_collide(next_pos, ahead):
			continue

		if _dist_to_exit(cur) < cur.rect.size.x:
			var build := _next_building()
			if build != null and not build.behaviour.can_accept(cur):
				continue

		if _will_exit(next_pos, cur):
			var build := _next_building()
			if build != null:
				items.remove_at(i)
				build.receive_item(cur)
			continue

		cur.position = next_pos


func can_accept(item: FactoryItem) -> bool:
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
	match rotation:
		FactoryBuilding.Rotation.NORMAL, FactoryBuilding.Rotation.FLIPPED:
			dist = abs(cur.position.y + cur.rect.size.y * 0.5 - rect.position.y - rect.size.y * 0.5)
		FactoryBuilding.Rotation.CLOCKWISE, FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			dist = abs(cur.position.x + cur.rect.size.x * 0.5 - rect.position.x - rect.size.x * 0.5)
		_:
			return true
	return dist < 0.005


func _step_toward_center(cur: FactoryItem) -> Vector2:
	match rotation:
		FactoryBuilding.Rotation.NORMAL, FactoryBuilding.Rotation.FLIPPED:
			var center_y := rect.position.y + rect.size.y * 0.5 - cur.rect.size.y * 0.5
			var diff := center_y - cur.position.y
			if abs(diff) <= ITEM_SPEED:
				return Vector2(cur.position.x, center_y)
			return Vector2(cur.position.x, cur.position.y + sign(diff) * ITEM_SPEED)
		FactoryBuilding.Rotation.CLOCKWISE, FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			var center_x := rect.position.x + rect.size.x * 0.5 - cur.rect.size.x * 0.5
			var diff := center_x - cur.position.x
			if abs(diff) <= ITEM_SPEED:
				return Vector2(center_x, cur.position.y)
			return Vector2(cur.position.x + sign(diff) * ITEM_SPEED, cur.position.y)
		_:
			return cur.position


func _dist_to_exit(cur: FactoryItem) -> float:
	match rotation:
		FactoryBuilding.Rotation.NORMAL:
			return rect.position.x + rect.size.x - (cur.position.x + cur.rect.size.x)
		FactoryBuilding.Rotation.FLIPPED:
			return cur.position.x - rect.position.x
		FactoryBuilding.Rotation.CLOCKWISE:
			return rect.position.y + rect.size.y - (cur.position.y + cur.rect.size.y)
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			return cur.position.y - rect.position.y
		_:
			return 0.0


func _next_building() -> FactoryBuilding:
	var p := _get_available_out_port()
	if p == null:
		return null
	var g := grid
	if g == null:
		return null
	return g.get_building(position + p.position + p.facing)


func _move_dir() -> Vector2:
	match rotation:
		FactoryBuilding.Rotation.NORMAL:
			return Vector2.RIGHT
		FactoryBuilding.Rotation.CLOCKWISE:
			return Vector2.DOWN
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			return Vector2.UP
		FactoryBuilding.Rotation.FLIPPED:
			return Vector2.LEFT
		_:
			return Vector2.RIGHT


func _progress(item: FactoryItem) -> float:
	match rotation:
		FactoryBuilding.Rotation.NORMAL:
			return item.position.x
		FactoryBuilding.Rotation.FLIPPED:
			return -item.position.x
		FactoryBuilding.Rotation.CLOCKWISE:
			return item.position.y
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			return -item.position.y
		_:
			return item.position.x


func _will_exit(next_pos: Vector2, cur: FactoryItem) -> bool:
	var center := next_pos + cur.rect.size * 0.5
	match rotation:
		FactoryBuilding.Rotation.NORMAL:
			return center.x >= rect.position.x + rect.size.x
		FactoryBuilding.Rotation.FLIPPED:
			return center.x <= rect.position.x
		FactoryBuilding.Rotation.CLOCKWISE:
			return center.y >= rect.position.y + rect.size.y
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			return center.y <= rect.position.y
		_:
			return false


func _would_collide(next_pos: Vector2, ahead: FactoryItem) -> bool:
	if ahead == null:
		return false
	return _calc_gap(next_pos, ahead) < ahead.rect.size.x


func _calc_gap(next_pos: Vector2, ahead: FactoryItem) -> float:
	match rotation:
		FactoryBuilding.Rotation.NORMAL:
			return ahead.position.x - next_pos.x
		FactoryBuilding.Rotation.FLIPPED:
			return next_pos.x - ahead.position.x
		FactoryBuilding.Rotation.CLOCKWISE:
			return ahead.position.y - next_pos.y
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			return next_pos.y - ahead.position.y
		_:
			return ahead.position.x - next_pos.x
