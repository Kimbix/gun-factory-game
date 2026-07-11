class_name Stat
extends RefCounted

var base: float
var value: float
var _modifiers: Array[StatModifier] = []


func _init(base_value: float) -> void:
	base = base_value
	value = base_value


func apply_modifier(source_id: StringName, mod_value: float) -> void:
	var modifier := StatModifier.new(source_id, mod_value)
	_modifiers.append(modifier)
	_recalculate()


func remove_modifier(source_id: StringName) -> void:
	for i: int in _modifiers.size():
		if _modifiers[i].source_id == source_id:
			_modifiers.remove_at(i)
			_recalculate()
			return


func has_modifier(source_id: StringName) -> bool:
	for modifier: StatModifier in _modifiers:
		if modifier.source_id == source_id:
			return true
	return false


func _recalculate() -> void:
	var total: float = base
	for modifier: StatModifier in _modifiers:
		total += modifier.value
	value = total
