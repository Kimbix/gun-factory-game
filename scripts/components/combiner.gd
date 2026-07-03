class_name Combiner
extends FactoryComponent

const ITEM_OUTPUT := preload("uid://cxut2uukg2odn")

var gunpowder_count: int = 0
var shells_count: int = 0
var _cooldown: int = 0
var _pending: int = 0


func tick() -> void:
	if _cooldown > 0:
		_cooldown -= 1
		if _cooldown == 0:
			if _can_output():
				_do_output()
			else:
				_pending += 1
		return

	if _pending > 0:
		if _can_output():
			_pending -= 1
			_do_output()
		return

	if gunpowder_count >= 1 and shells_count >= 1:
		gunpowder_count -= 1
		shells_count -= 1
		_cooldown = 60


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
	grid.place_item(ITEM_OUTPUT, where_to)
