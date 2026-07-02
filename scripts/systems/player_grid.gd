class_name PlayerGrid
extends Node

@warning_ignore("unused_signal")
signal output_item(item: FactoryItem)

const GRID_TEXTURE_SIZE := 16

@export var dimensions: Vector2i = Vector2i(10, 10)

var _floor: Dictionary[Vector2i, Texture2D] = { }
var _items: Array[FactoryItem] = []
var _buildings: Dictionary[Vector2i, FactoryBuilding] = { }


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
	return 0


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

	var building := FactoryBuilding.new(self, what, where)
	_buildings[where] = building
	building.rotation = _rotation


func place_item(what: FactoryItemInfo, where: Vector2) -> void:
	if what == null:
		print("GridComponentInfo cannot be null")
		return

	# NOTE: This check will probably have to be more thorough when NxM buildings are in play
	if where.x < 0 or where.x >= dimensions.x or where.y < 0 or where.y >= dimensions.y:
		print("Position for building must be valid")
		return

	var building_to_check := where.floor()
	var building := get_building(building_to_check)

	var item := FactoryItem.new(what, where)
	_items.append(item)
	if building != null:
		building.receive_item(item)


func initialize_empty() -> void:
	_clear_grid()

	for v: Vector2i in VectorTools.vector2i_range(dimensions):
		_floor[v] = preload("uid://bcxv8tx5ovn5l")


func tick() -> void:
	for v: Vector2i in _buildings.keys():
		var building := _buildings[v]
		building.tick()


func set_building_var(n: StringName, v: Variant, p: Vector2i) -> void:
	if not _buildings.has(p):
		return
	_buildings[p].set_var(n, v)


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
		_buildings[i] = null
	_buildings.clear()
