class_name ToxicBulletEffect
extends EffectStrategy


func _init() -> void:
	effect_name = &"toxic"
	incompatible_with = []


func apply_on_hit(_target: Node2D, _projectile: Node2D) -> void:
	print("TOXIC_BULLET_ENHANCEMENT")
