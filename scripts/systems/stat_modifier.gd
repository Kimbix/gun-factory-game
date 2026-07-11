class_name StatModifier
extends RefCounted

var source_id: StringName
var value: float


func _init(p_source_id: StringName, p_value: float) -> void:
	source_id = p_source_id
	value = p_value
