class_name BlockInventory
extends RefCounted

const MAX_STACK_SIZE := 9999

var slots: Dictionary[int, InventorySlot]
var slot_limit: int

var _accepted_types: Dictionary # Dictionary[FactoryItemInfo, bool] — used as a set


func _init(limit: int) -> void:
	slot_limit = limit


func set_accept_filter(allowed: Array[FactoryItemInfo]) -> void:
	_accepted_types.clear()
	for info in allowed:
		_accepted_types[info] = true


func _is_accepted(info: FactoryItemInfo) -> bool:
	if _accepted_types.is_empty():
		return true
	return _accepted_types.has(info)


func can_accept(item: FactoryItem) -> bool:
	var info := item.get_info()
	if not _is_accepted(info):
		return false
	for i in slot_limit:
		if not slots.has(i):
			return true
		if slots[i].item_info == info and slots[i].count < MAX_STACK_SIZE:
			return true
	return false


func has(info: FactoryItemInfo, amount: int = 1) -> bool:
	var total := 0
	for i in slot_limit:
		if not slots.has(i):
			continue
		if slots[i].item_info == info:
			total += slots[i].count
			if total >= amount:
				return true
	return false


func add(item: FactoryItem) -> bool:
	var info := item.get_info()
	if not _is_accepted(info):
		return false
	for i in slot_limit:
		if slots.has(i) and slots[i].item_info == info and slots[i].count < MAX_STACK_SIZE:
			slots[i].count += 1
			return true
	for i in slot_limit:
		if not slots.has(i):
			slots[i] = InventorySlot.new(info)
			slots[i].count = 1
			return true
	return false


func remove(info: FactoryItemInfo, amount: int = 1) -> int:
	var remaining := amount
	for i in slot_limit:
		if not slots.has(i):
			continue
		if slots[i].item_info == info:
			var to_remove := mini(remaining, slots[i].count)
			slots[i].count -= to_remove
			remaining -= to_remove
			if slots[i].count == 0:
				slots.erase(i)
			if remaining == 0:
				return amount
	return amount - remaining


class InventorySlot:
	var item_info: FactoryItemInfo
	var count: int


	func _init(info: FactoryItemInfo) -> void:
		item_info = info
		count = 0
