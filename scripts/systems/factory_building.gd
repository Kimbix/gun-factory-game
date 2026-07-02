class_name FactoryBuilding
extends RefCounted

enum Rotation {
	NORMAL,
	CLOCKWISE,
	COUNTERCLOCKWISE,
	FLIPPED,
}

var grid: PlayerGrid
var rotation: Rotation = Rotation.NORMAL:
	get():
		return rotation
	set(v):
		rotation = v

		ports.clear() # Clear ports
		for i: Port in _info.ports:
			ports.append(i.duplicate()) # Get new ones

		for p: Port in ports: # Rotate them accordingly
			match rotation:
				Rotation.NORMAL:
					pass
				Rotation.CLOCKWISE:
					p.facing = Vector2i(-p.facing.y, p.facing.x)
				Rotation.COUNTERCLOCKWISE:
					p.facing = Vector2i(p.facing.y, -p.facing.x)
				Rotation.FLIPPED:
					p.facing = Vector2i(-p.facing.x, -p.facing.y)
var rect: Rect2
var position: Vector2i
var behaviour: FactoryComponent
var texture: Texture2D:
	get():
		return _info.texture
var ports: Array[Port] = []
var _info: GridComponentInfo


func _init(
		_grid: PlayerGrid,
		info: GridComponentInfo,
		_position: Vector2i,
		_rotation: FactoryBuilding.Rotation,
) -> void:
	_info = info
	position = _position
	grid = _grid
	rect = Rect2(_position, info.dimensions)
	rotation = _rotation

	if _info.behaviour != null:
		behaviour = _info.behaviour.new()
		behaviour.building = self


func tick() -> void:
	if behaviour == null:
		return
	behaviour.tick()


func receive_item(item: FactoryItem) -> void:
	if behaviour == null:
		return
	behaviour.receive_item(item)


func set_var(n: StringName, v: Variant) -> void:
	if behaviour == null:
		return
	behaviour.set_var(n, v)
