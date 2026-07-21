class_name ExperienceSpawner
extends Node2D

static var crystals: Dictionary[int, PackedScene] = {
	1: preload("uid://r5gdpvcp6gx3"),
}

@export var spawn_radius: float = 16.0


func spawn() -> void:
	if crystals.is_empty():
		return

	var enemy := get_parent() as BaseEnemy
	if enemy == null:
		return

	var origin := enemy.global_position
	var amount := maxi(enemy.xp_amount, 0)

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
