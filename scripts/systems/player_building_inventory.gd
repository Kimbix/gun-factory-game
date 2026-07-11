class_name PlayerBuildingInventory
extends RefCounted

signal changed

var _buildings: Array[GridComponentInfo] = []


func add(info: GridComponentInfo) -> void:
	_buildings.append(info)
	changed.emit()


func remove_at(index: int) -> GridComponentInfo:
	var info := _buildings[index]
	_buildings.remove_at(index)
	changed.emit()
	return info


func get_at(index: int) -> GridComponentInfo:
	return _buildings[index]


func get_all() -> Array[GridComponentInfo]:
	return _buildings.duplicate()


func size() -> int:
	return _buildings.size()


func is_empty() -> bool:
	return _buildings.is_empty()
