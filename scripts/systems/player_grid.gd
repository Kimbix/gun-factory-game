class_name PlayerGrid
extends Node

@warning_ignore("unused_signal")
signal output_item(item: FactoryItem)
signal building_placed(building: FactoryBuilding)
signal building_removed(building: FactoryBuilding)
@warning_ignore("unused_signal")
signal overlay_changed(position: Vector2i)

@export var dimensions: Vector2i = Vector2i(10, 10)

const _FLOOR_TEX := preload("uid://bcxv8tx5ovn5l")

var _floor: Dictionary[Vector2i, Texture2D] = { }
var _items: Array[FactoryItem] = []
var _buildings: Dictionary[Vector2i, FactoryBuilding] = { }


func destroy_building(v: Vector2i) -> void:
	if not has_building(v):
		return

	var building := _buildings[v]
	building_removed.emit(building)
	building.free_resources()
	print("Erasing building at %s" % v)
	_buildings.erase(v)


func rotate_building(v: Vector2i, clockwise: bool = true) -> void:
	var r := get_building_rotation(v)
	r = FactoryBuilding.rotate(r, clockwise)
	set_building_rotation(v, r)


func set_building_rotation(v: Vector2i, rotation: FactoryBuilding.Rotation) -> void:
	if not has_building(v):
		return
	var b := get_building(v)
	b.rotation = rotation


func destroy_item(what: FactoryItem) -> void:
	if _items.has(what):
		_items.erase(what)


func get_item_count() -> int:
	return _items.size()


func get_item_texture(id: int) -> Texture2D:
	return _items[id].texture


func get_item_position(id: int) -> Vector2:
	return _items[id].position


func get_floor_texture(v: Vector2i) -> Texture2D:
	if _floor.has(v):
		return _floor[v]
	return null


func has_building(v: Vector2i) -> bool:
	return _buildings.has(v) and _buildings[v] != null


func get_building(v: Vector2i) -> FactoryBuilding:
	return _buildings[v] if _buildings.has(v) else null


func get_building_ports(v: Vector2i) -> Array[Port]:
	if not _buildings.has(v):
		return []
	return _buildings[v].ports


func get_building_rotation(v: Vector2i) -> FactoryBuilding.Rotation:
	if _buildings.has(v) and _buildings[v] != null:
		return _buildings[v].rotation
	return FactoryBuilding.Rotation.NORMAL


func get_building_texture(v: Vector2i) -> Texture2D:
	if _buildings.has(v) and _buildings[v] != null:
		return _buildings[v].texture
	return null


func place_building(
		what: GridComponentInfo,
		where: Vector2i,
		_rotation: FactoryBuilding.Rotation = FactoryBuilding.Rotation.NORMAL,
) -> void:
	if what == null:
		print("GridComponentInfo cannot be null")
		return

	# NOTE: This check will probably have to be more thorough when NxM buildings are in play
	if where.x < 0 or where.x >= dimensions.x or where.y < 0 or where.y >= dimensions.y:
		print("Position for building must be valid")
		return

	var building := FactoryBuilding.new(self, what, where, _rotation)
	_buildings[where] = building
	building_placed.emit(building)


func place_item(item: FactoryItem) -> void:
	if item == null:
		print("Item cannot be null")
		return

	var pos := item.position
	if pos.x < 0 or pos.x >= dimensions.x or pos.y < 0 or pos.y >= dimensions.y:
		print("Position for item must be valid")
		return

	var building_to_check := pos.floor()
	var building := get_building(building_to_check)

	if building != null and not building.behaviour.can_accept(item):
		return
	_items.append(item)
	if building != null:
		building.receive_item(item)


func initialize_empty() -> void:
	_clear_grid()

	for v: Vector2i in VectorTools.vector2i_range(dimensions):
		_floor[v] = _FLOOR_TEX


func tick() -> void:
	for v: Vector2i in _buildings.keys():
		var building := _buildings[v]
		building.tick()


func set_building_var(n: StringName, v: Variant, p: Vector2i) -> void:
	if not _buildings.has(p):
		return
	_buildings[p].set_var(n, v)


func to_data() -> PlayerGridData:
	var data := PlayerGridData.new()
	data.dimensions = dimensions
	data.floor_textures = _floor.duplicate(true)

	for v: Vector2i in _buildings.keys():
		var b := _buildings[v]
		var entry := BuildingEntry.new()
		entry.position = v
		entry.rotation = b.rotation
		entry.info = b.get_info()
		entry.variables = b.get_vars()
		data.buildings.append(entry)

	data.preview = _generate_preview()

	return data


func from_data(data: PlayerGridData) -> void:
	_clear_grid()
	_items.clear()
	dimensions = data.dimensions
	for k: Variant in data.floor_textures:
		_floor[k as Vector2i] = data.floor_textures[k] as Texture2D

	var expected_floor := dimensions.x * dimensions.y
	if _floor.size() != expected_floor:
		print("WARNING: floor cnt %d ≠ %dx%d" % [_floor.size(), dimensions.x, dimensions.y])
		if _floor.size() > expected_floor:
			var to_remove: Array[Vector2i] = []
			for v: Vector2i in _floor:
				if v.x >= dimensions.x or v.y >= dimensions.y:
					to_remove.append(v)
			for v: Vector2i in to_remove:
				_floor.erase(v)
		else:
			for v: Vector2i in VectorTools.vector2i_range(dimensions):
				if not _floor.has(v):
					_floor[v] = _FLOOR_TEX

		var buildings_to_remove: Array[Vector2i] = []
		for v: Vector2i in _buildings:
			if v.x >= dimensions.x or v.y >= dimensions.y:
				buildings_to_remove.append(v)
		for v: Vector2i in buildings_to_remove:
			_buildings[v].free_resources()
			_buildings.erase(v)

	for entry: BuildingEntry in data.buildings:
		var rotation := entry.rotation as FactoryBuilding.Rotation
		place_building(entry.info, entry.position, rotation)
		for n: StringName in entry.variables:
			set_building_var(n, entry.variables[n], entry.position)


func _generate_preview() -> Image:
	var img := Image.create(dimensions.x, dimensions.y, false, Image.FORMAT_RGB8)
	for x in dimensions.x:
		for y in dimensions.y:
			var v := Vector2i(x, y)
			if has_building(v):
				img.set_pixel(x, y, get_building(v).get_info().color)
			else:
				img.set_pixel(x, y, Color.BLACK)
	return img


func _clear_grid() -> void:
	for i: Vector2i in _floor.keys():
		var obj: Texture2D = _floor[i]
		if obj == null:
			continue
		_floor[i] = null
	_floor.clear()

	for i: Vector2i in _buildings.keys():
		var obj: FactoryBuilding = _buildings[i]
		if obj == null:
			continue
		obj.free_resources()
		_buildings[i] = null
	_buildings.clear()
