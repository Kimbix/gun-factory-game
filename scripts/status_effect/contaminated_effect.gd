class_name ContaminatedEffect
extends StatusEffect

const SCENE := preload("res://objects/effects/contaminated_particles.tscn")


func _init() -> void:
	effect_name = &"contaminated"
	duration = 4.0
	refreshes_others = true
	scaling = LinearScaling.new(1.0, 0.5)


func on_afflict(enemy: BaseEnemy) -> void:
	enemy.damage_taken_multiplier = get_magnitude()
	_particles = SCENE.instantiate()
	enemy.add_child(_particles)


func apply_effect(magnitude: float, _delta: float, enemy: BaseEnemy) -> void:
	enemy.damage_taken_multiplier = magnitude


func on_remove(enemy: BaseEnemy) -> void:
	enemy.damage_taken_multiplier = 1.0
	if _particles:
		_particles.emitting = false
		_particles.get_tree().create_timer(_particles.lifetime).timeout.connect(_particles.queue_free)
		_particles = null
