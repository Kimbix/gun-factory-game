class_name Furnace
extends FactoryComponent

const CRAFT_TIME := 60
const OUTPUT_ITEM := preload("uid://c0nkegvlqof7")

var lead_count: int = 0
var _cooldown: int = 0


func tick() -> void:
	if lead_count == 0:
		_cooldown = 0

	if _cooldown > 0:
		_cooldown -= 1
		if _cooldown == 0:
			if _can_output():
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
	var where_to: Vector2 = position + p.position + p.facing
	grid.place_item(OUTPUT_ITEM, where_to)


func receive_item(item: FactoryItem) -> void:
	if item.name == &"raw_lead":
		lead_count += 1
	grid.destroy_item(item)
