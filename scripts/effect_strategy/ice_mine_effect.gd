class_name IceMineEffect
extends EffectStrategy


func _init() -> void:
	effect_name = &"ice"
	incompatible_with = []


func apply_on_hit(_target: Node2D, _projectile: Node2D) -> void:
	print("ICE_MINE_ENHANCEMENT")
