class_name Stat
extends RefCounted

var base: float
var value: float
var diminishing_asymptote: float = 0.0
var use_diminishing: bool = false
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
	if use_diminishing:
		var max_delta := diminishing_asymptote - base
		var raw_delta := total - base
		var completion := clampf(raw_delta / max_delta, -1.0, 1.0) if max_delta != 0.0 else 0.0
		var dim_ratio := 1.0 - exp(-abs(completion))
		value = base + max_delta * signf(completion) * dim_ratio
	else:
		value = total
