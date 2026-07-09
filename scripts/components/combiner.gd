class_name Combiner
extends FactoryComponent

const COOLDOWN := 20
const ITEM_OUTPUT := preload("uid://cxut2uukg2odn")

var gunpowder_count: int = 0
var shells_count: int = 0
var _cooldown: int = 0
var _pending: int = 0


func tick() -> void:
	if _cooldown > 0:
		_cooldown -= 1
		if _cooldown == 0:
			var port := _get_available_out_port()
			if port != null and _can_output() and _can_output_to(ITEM_OUTPUT, port):
				_do_output()
			else:
				_pending += 1
		return

	if _pending > 0:
		var port := _get_available_out_port()
		if port != null and _can_output() and _can_output_to(ITEM_OUTPUT, port):
			_pending -= 1
			_do_output()
		return

	if gunpowder_count >= 1 and shells_count >= 1:
		gunpowder_count -= 1
		shells_count -= 1
		_cooldown = COOLDOWN


func get_vars() -> Dictionary:
	return {
		&"gunpowder_count": gunpowder_count,
		&"shells_count": shells_count,
		&"_cooldown": _cooldown,
		&"_pending": _pending,
	}


func receive_item(item: FactoryItem) -> void:
	if item.name == &"bullet_casing":
		shells_count += 1
	elif item.name == &"gunpowder":
		gunpowder_count += 1
	print(shells_count, gunpowder_count)
	grid.destroy_item(item)


func _do_output() -> void:
	var p := _get_available_out_port()
	if p == null:
		return
	var where_to: Vector2 = position + p.position + p.facing
	grid.place_item(FactoryItem.new(ITEM_OUTPUT, where_to))
