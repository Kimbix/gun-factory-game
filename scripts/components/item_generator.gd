class_name ItemGenerator
extends FactoryComponent

var generating: FactoryItemInfo
var _cooldown: int = 0


func tick() -> void:
	if _cooldown > 0:
		_cooldown -= 1
		return
	if not _can_output():
		return
	var output_port := _get_available_out_port()
	if output_port == null:
		return
	var where_to := position + output_port.position + output_port.facing
	grid.place_item(generating, where_to)
	_cooldown = 40
