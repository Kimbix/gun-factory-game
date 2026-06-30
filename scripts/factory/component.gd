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


func _rotate(v: Vector2i, rotation: int) -> Vector2i:
	match rotation % 4:
		0:
			return v
		1:
			return Vector2i(-v.y, v.x)
		2:
			return -v
		3:
			return Vector2i(v.y, -v.x)
	return v
