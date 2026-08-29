class_name EffectStrategy
extends RefCounted

var effect_name: StringName = &""
var incompatible_with: Array[StringName] = []


func is_compatible_with(existing_effects: Array[EffectStrategy]) -> bool:
	for other in existing_effects:
		if other.effect_name in incompatible_with:
			return false
		if effect_name in other.incompatible_with:
			return false
	return true


func apply_on_hit(_target: Node2D, _projectile: Node2D) -> void:
	pass


func update(_delta: float, _projectile: Node2D) -> void:
	pass
