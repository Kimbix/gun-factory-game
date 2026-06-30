class_name Inventory
extends RefCounted

const MAX_SLOTS := 8
const MAX_STACK := 9999

var slots: Array[InventorySlot] = []


func _init() -> void:
	for i in MAX_SLOTS:
		slots.append(InventorySlot.new())


func add_item(type: ComponentType, count: int = 1) -> int:
	var remaining := count
	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty() and slot.component_type == type and slot.count < MAX_STACK:
			var space := MAX_STACK - slot.count
			var add := mini(remaining, space)
			slot.count += add
			remaining -= add
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			slot.component_type = type
			slot.count = mini(remaining, MAX_STACK)
			remaining -= slot.count
	return remaining


func remove_item(type: ComponentType, count: int = 1) -> bool:
	if count_item(type) < count:
		return false
	var remaining := count
	for slot in slots:
		if remaining <= 0:
			break
		if slot.component_type == type:
			var take := mini(remaining, slot.count)
			slot.count -= take
			remaining -= take
			if slot.count <= 0:
				slot.clear()
	return true


func count_item(type: ComponentType) -> int:
	var total := 0
	for slot in slots:
		if slot.component_type == type:
			total += slot.count
	return total


func has_item(type: ComponentType) -> bool:
	return count_item(type) > 0


func get_slot(index: int) -> InventorySlot:
	return slots[index] if index >= 0 and index < MAX_SLOTS else null
