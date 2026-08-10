class_name Combiner
extends FactoryComponent

const COOLDOWN := 15

var gunpowder_count: int = 0
var shells_count: int = 0
var _cooldown: int = 0
var _pending: int = 0


func tick() -> void:
	var output := (building.get_info().config as MachineConfig).output_item
	if _cooldown > 0:
		_cooldown -= 1
		if _cooldown == 0:
			if not (_can_output() and _output_item(output)):
				_pending += 1
		return

	if _pending > 0:
		if _can_output() and _output_item(output):
			_pending -= 1
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
	var g := grid
	if g == null:
		return
	g.destroy_item(item)
