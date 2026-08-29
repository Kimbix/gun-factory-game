class_name IceGrenadeEffect
extends EffectStrategy


func _init() -> void:
	effect_name = &"ice"
	incompatible_with = []


func apply_on_hit(_target: Node2D, _projectile: Node2D) -> void:
	print("ICE_GRENADE_ENHANCEMENT")
