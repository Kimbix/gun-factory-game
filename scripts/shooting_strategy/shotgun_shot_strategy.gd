class_name ShotgunShotStrategy
extends ShootingStrategy

const BULLET := preload("res://objects/bullet.tscn")
const PELLET_COUNT := 9
const SPREAD_DEG := 45.0
const DAMAGE := 5


func execute(shooter: Node2D, target: Node2D, _item: FactoryItem) -> void:
	var base_dir := (target.global_position - shooter.global_position).normalized()
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for _i in PELLET_COUNT:
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)
		var speed := 800.0 * randf_range(0.75, 1.25)

		var bullet := BULLET.instantiate()
		bullet.direction = dir
		bullet.global_position = shooter.global_position
		bullet.speed = speed
		bullet.damage = DAMAGE
		shooter.get_parent().add_child(bullet)
