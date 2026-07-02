class_name ConveyorBelt
extends FactoryComponent

const MOVE_DIRECTION: Dictionary[FactoryBuilding.Rotation, Vector2] = {
	FactoryBuilding.Rotation.NORMAL: Vector2.RIGHT,
	FactoryBuilding.Rotation.CLOCKWISE: Vector2.DOWN,
	FactoryBuilding.Rotation.COUNTERCLOCKWISE: Vector2.UP,
	FactoryBuilding.Rotation.FLIPPED: Vector2.LEFT,
}
const CHECK_METHOD: Dictionary[FactoryBuilding.Rotation, StringName] = {
	FactoryBuilding.Rotation.NORMAL: &"_normal_rotation_check",
	FactoryBuilding.Rotation.CLOCKWISE: &"_clockwise_rotation_check",
	FactoryBuilding.Rotation.COUNTERCLOCKWISE: &"_counterclockwise_rotation_check",
	FactoryBuilding.Rotation.FLIPPED: &"_flipped_rotation_check",
}

var items: Array[FactoryItem] = []


func tick() -> void:
	var dir := MOVE_DIRECTION[rotation]
	var check := CHECK_METHOD[rotation]
	for i: FactoryItem in items.duplicate():
		var new_rect := i.rect
		new_rect.position += dir * .05

		if call(check, new_rect):
			i.position += dir * .05
			continue

		var p := _get_available_out_port()
		if p == null:
			continue
		var build := grid.get_building(position + p.position + p.facing)
		if build != null and _can_output():
			items.erase(i)
			build.receive_item(i)


func receive_item(item: FactoryItem) -> void:
	items.append(item)


func _normal_rotation_check(r: Rect2) -> bool:
	return r.position.x + r.size.x * .5 < rect.position.x + rect.size.x


func _clockwise_rotation_check(r: Rect2) -> bool:
	return r.position.y + r.size.y * .5 < rect.position.y + rect.size.y


func _counterclockwise_rotation_check(r: Rect2) -> bool:
	return r.position.y + r.size.y * .5 > rect.position.y


func _flipped_rotation_check(r: Rect2) -> bool:
	return r.position.x + r.size.x * .5 > rect.position.x
