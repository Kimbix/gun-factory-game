class_name InventorySlot
extends RefCounted

var component_type: ComponentType = null
var count: int = 0


func is_empty() -> bool:
	return component_type == null or count <= 0


func clear() -> void:
	component_type = null
	count = 0
