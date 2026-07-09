class_name ConveyorSplitter
extends FactoryComponent

var _entering: Array[FactoryItem] = []
var _lanes: Array[Array] = [[], [], []]
var _next_lane: int = 0
var _cached_in_port: Port
var _cached_out_ports: Array[Port]
var _last_rotation: FactoryBuilding.Rotation


func tick() -> void:
	if not _refresh_cache():
		return

	var enter_dir := -Vector2(_cached_in_port.facing)
	var tile_center := Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * 0.5,
	)

	for i: FactoryItem in _entering.duplicate():
		i.position += enter_dir * 0.05
		if _passed_point(i.position + i.rect.size * 0.5, tile_center, enter_dir):
			_entering.erase(i)
			_lanes[_next_lane].append(i)
			_next_lane = (_next_lane + 1) % 3

	for idx: int in 3:
		var exit_dir := Vector2(_cached_out_ports[idx].facing)
		var port := _cached_out_ports[idx]
		for i: FactoryItem in _lanes[idx].duplicate():
			var new_center := i.position + i.rect.size * 0.5 + exit_dir * 0.05
			if _within_rect(new_center, exit_dir):
				i.position += exit_dir * 0.05
			else:
				var build := grid.get_building(position + port.position + port.facing)
				if build != null:
					_lanes[idx].erase(i)
					build.receive_item(i)


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


func _passed_point(p: Vector2, target: Vector2, dir: Vector2) -> bool:
	if dir.x > 0:
		return p.x >= target.x
	elif dir.x < 0:
		return p.x <= target.x
	elif dir.y > 0:
		return p.y >= target.y
	else:
		return p.y <= target.y


func _within_rect(p: Vector2, dir: Vector2) -> bool:
	if dir.x > 0:
		return p.x < rect.position.x + rect.size.x
	elif dir.x < 0:
		return p.x > rect.position.x
	elif dir.y > 0:
		return p.y < rect.position.y + rect.size.y
	else:
		return p.y > rect.position.y
