class_name OnFireEffect
extends StatusEffect

const SCENE := preload("res://objects/effects/fire_particles.tscn")


func _init() -> void:
	effect_name = &"on_fire"
	duration = 3.0
	refreshes_others = false
	scaling = LinearScaling.new(2.0, 1.0)


func on_afflict(enemy: BaseEnemy) -> void:
	_particles = SCENE.instantiate()
	enemy.add_child(_particles)


func apply_effect(magnitude: float, delta: float, enemy: BaseEnemy) -> void:
	var dps := ceili(magnitude)
	enemy.take_damage(dps, &"on_fire")


func on_remove(enemy: BaseEnemy) -> void:
	if _particles:
		_particles.emitting = false
		_particles.get_tree().create_timer(_particles.lifetime).timeout.connect(_particles.queue_free)
		_particles = null
