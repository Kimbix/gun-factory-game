class_name FrostedEffect
extends StatusEffect

const SCENE := preload("res://objects/effects/frost_particles.tscn")


func _init() -> void:
	effect_name = &"frosted"
	duration = 2.0
	refreshes_others = true
	scaling = LinearScaling.new(0.1, 0.05)


func on_afflict(enemy: BaseEnemy) -> void:
	enemy.speed_multiplier = get_magnitude()
	_particles = SCENE.instantiate()
	enemy.add_child(_particles)


func apply_effect(magnitude: float, _delta: float, enemy: BaseEnemy) -> void:
	enemy.speed_multiplier = magnitude


func on_remove(enemy: BaseEnemy) -> void:
	enemy.speed_multiplier = 1.0
	if _particles:
		_particles.emitting = false
		var tree := _particles.get_tree()
		tree.create_timer(_particles.lifetime).timeout.connect(
			_particles.queue_free,
		)
		_particles = null
