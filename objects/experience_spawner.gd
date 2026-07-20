class_name ExperienceSpawner
extends Node2D

static var crystals: Dictionary[int, PackedScene] = {
	1: preload("uid://r5gdpvcp6gx3"),
}

@export var base_xp: int = 5
@export_range(0.0, 1.0) var variance: float = 0.2
@export var spawn_radius: float = 16.0


func spawn() -> void:
	if crystals.is_empty():
		return

	var parent := get_parent() as Node2D
	if parent == null:
		return

	var amount := roundi(base_xp * randf_range(1.0 - variance, 1.0 + variance))
	amount = maxi(amount, 0)
	var origin := parent.global_position

	call_deferred("_do_spawn_deferred", amount, origin)


func _do_spawn_deferred(amount: int, origin: Vector2) -> void:
	var values := crystals.keys()
	values.sort()
	values.reverse()

	for value: int in values:
		var scene: PackedScene = crystals[value]
		if scene == null:
			continue
		var count := int(float(amount) / float(value))
		amount -= count * value

		for i: int in count:
			var crystal := scene.instantiate() as ExperienceCrystal
			if crystal == null:
				continue
			crystal.xp_value = value
			var offset := Vector2.RIGHT.rotated(randf() * TAU) * randf() * spawn_radius
			crystal.global_position = origin + offset
			var enemy := get_parent() as BaseEnemy
			if enemy == null or enemy.game_world == null:
				continue
			enemy.game_world.add_child(crystal)
