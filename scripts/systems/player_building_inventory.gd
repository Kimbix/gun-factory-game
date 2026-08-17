class_name PlayerBuildingInventory
extends RefCounted

signal changed

var _stacks: Array[BuildingStack] = []


func add(info: GridComponentInfo, amount: int = 1) -> void:
	for stack in _stacks:
		if stack.info == info:
			stack.count += amount
			changed.emit()
			return
	var stack := BuildingStack.new()
	stack.info = info
	stack.count = amount
	_stacks.append(stack)
	changed.emit()


func remove(info: GridComponentInfo, amount: int = 1) -> bool:
	for i in _stacks.size():
		if _stacks[i].info == info:
			_stacks[i].count -= amount
			if _stacks[i].count <= 0:
				_stacks.remove_at(i)
			changed.emit()
			return true
	return false


func get_count(info: GridComponentInfo) -> int:
	for stack in _stacks:
		if stack.info == info:
			return stack.count
	return 0


func has(info: GridComponentInfo, amount: int = 1) -> bool:
	return get_count(info) >= amount


func get_stacks() -> Array[BuildingStack]:
	return _stacks.duplicate()


func size() -> int:
	return _stacks.size()


func total_count() -> int:
	var total := 0
	for stack in _stacks:
		total += stack.count
	return total


func is_empty() -> bool:
	return _stacks.is_empty()
