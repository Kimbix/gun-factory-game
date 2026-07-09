class_name SpreadShotStrategy
extends ShootingStrategy

const BULLET := preload("res://objects/bullet.tscn")
const BULLET_COUNT := 15
const DAMAGE := 3
const SPREAD_DEG := 60.0
const DELAY := 0.05


func execute(shooter: Node2D, target: Node2D, _item: FactoryItem) -> void:
	var base_dir := (target.global_position - shooter.global_position).normalized()
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for _i in BULLET_COUNT:
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)
		var speed := 600.0 * randf_range(0.95, 1.05)

		var bullet := BULLET.instantiate()
		bullet.direction = dir
		bullet.global_position = shooter.global_position
		bullet.speed = speed
		bullet.damage = DAMAGE
		shooter.get_parent().add_child(bullet)

		await shooter.get_tree().create_timer(DELAY).timeout
