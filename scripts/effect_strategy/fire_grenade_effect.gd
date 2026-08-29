class_name FireGrenadeEffect
extends EffectStrategy


func _init() -> void:
	effect_name = &"fire"
	incompatible_with = []


func apply_on_hit(target: Node2D, _projectile: Node2D) -> void:
	if target is BaseEnemy:
		target.add_status_effect(OnFireEffect.new())
