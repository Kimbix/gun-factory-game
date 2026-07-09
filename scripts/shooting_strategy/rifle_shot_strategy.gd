class_name RifleShotStrategy
extends ShootingStrategy

const BULLET := preload("res://objects/bullet.tscn")
const BURST_COUNT := 3
const DAMAGE := 10
const SPREAD_DEG := 5.0
const DELAY := 0.1
const SPEED := 1200.0


func execute(shooter: Node2D, target: Node2D, _item: FactoryItem) -> void:
	var base_dir := (target.global_position - shooter.global_position).normalized()
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for _i in BURST_COUNT:
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)

		var bullet := BULLET.instantiate()
		bullet.direction = dir
		bullet.global_position = shooter.global_position
		bullet.speed = SPEED
		bullet.damage = DAMAGE
		shooter.get_parent().add_child(bullet)

		await shooter.get_tree().create_timer(DELAY).timeout
