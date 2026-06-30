class_name Component
extends RefCounted
## A placed factory component. Holds a reference to its ComponentType + position.

var type: ComponentType
var origin: Vector2i = Vector2i.ZERO
## 0 = East-facing, 1 = South, 2 = West, 3 = North.
var rotation: int = 0
## Item currently sitting on this component's cell (null if empty). One item per cell.
var item: Item = null


func _init(p_type: ComponentType = null) -> void:
	type = p_type


func _to_string() -> String:
	return "Component(%s @ %s rot=%d)" % [type.resource_name if type else "?", origin, rotation]


## Cells this component occupies given an origin and rotation.
func footprint_cells(p_origin: Vector2i, p_rotation: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for offset in type.footprint:
		out.append(p_origin + _rotate(offset, p_rotation))
	return out


## Unit vector for this component's facing direction (East / South / West / North).
func facing_vector() -> Vector2i:
	match rotation % 4:
		0:
			return Vector2i(1, 0)
		1:
			return Vector2i(0, 1)
		2:
			return Vector2i(-1, 0)
		3:
			return Vector2i(0, -1)
	return Vector2i.ZERO


## Returns this component's ports with faces rotated by `rotation`.
## Each entry: {face: Vector2i (relative offset), role: StringName (&"in" | &"out")}.
func rotated_ports() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for port in type.ports:
		out.append({
			&"face": _rotate(port.face, rotation),
			&"role": port.role,
		})
	return out


## Whether this component accepts items pushed from the given cell.
func can_receive_from(from_cell: Vector2i) -> bool:
	var dir := from_cell - origin
	for port in rotated_ports():
		if port.role == &"in" and port.face == dir:
			return true
	return false


func _rotate(v: Vector2i, p_rotation: int) -> Vector2i:
	match p_rotation % 4:
		0:
			return v
		1:
			return Vector2i(-v.y, v.x)
		2:
			return -v
		3:
			return Vector2i(v.y, -v.x)
	return v
