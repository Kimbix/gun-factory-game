class_name FireMineEffect
extends EffectStrategy


func _init() -> void:
	effect_name = &"fire"
	incompatible_with = []


func apply_on_hit(_target: Node2D, _projectile: Node2D) -> void:
	print("FIRE_MINE_ENHANCEMENT")
