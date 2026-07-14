class_name Furnace
extends FactoryComponent

const CRAFT_TIME := 20

var lead_count: int = 0
var _cooldown: int = 0


func setup() -> void:
	var s := ItemOverlayStrategy.new()
	s.item_info = (building.get_info().config as MachineConfig).output_item
	overlay_strategy = s


func tick() -> void:
	var output := (building.get_info().config as MachineConfig).output_item
	if _cooldown > 0:
		_cooldown -= 1
		if _cooldown == 0:
			var port := _get_available_out_port()
			if port != null and _can_output() and _can_output_to(output, port):
				_do_output()
			else:
				_cooldown = 1
		return

	if lead_count > 0:
		lead_count -= 1
		_cooldown = CRAFT_TIME


func _do_output() -> void:
	var p := _get_available_out_port()
	if p == null:
		return
	var output := (building.get_info().config as MachineConfig).output_item
	var where_to: Vector2 = position + p.position + p.facing
	grid.place_item(FactoryItem.new(output, where_to))


func get_vars() -> Dictionary:
	return {
		&"lead_count": lead_count,
		&"_cooldown": _cooldown,
	}


func receive_item(item: FactoryItem) -> void:
	if item.name == &"raw_lead":
		lead_count += 1
	grid.destroy_item(item)
