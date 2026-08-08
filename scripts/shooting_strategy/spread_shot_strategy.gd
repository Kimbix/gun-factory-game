class_name SpreadShotStrategy
extends ShootingStrategy

const BULLET_COUNT := 15
const DAMAGE := 3
const SPREAD_DEG := 60.0
const DELAY := 0.05
const BULLET_SCENE := preload("res://objects/projectiles/bullet_spread.tscn")

var _burst_active := false


func execute(
		shooter: Node2D,
		target: Node2D,
		_item: FactoryItem,
		player_stats: PlayerStats = null,
) -> void:
	if _burst_active:
		return
	_burst_active = true
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for i in BULLET_COUNT:
		if not is_instance_valid(shooter):
			_burst_active = false
			return

		if not is_instance_valid(target):
			target = shooter.find_target()
			if target == null:
				_burst_active = false
				return

		var base_dir := (target.global_position - shooter.global_position).normalized()
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)
		var speed := 600.0 * randf_range(0.95, 1.05)

		spawn_bullet(BULLET_SCENE, shooter, dir, speed, DAMAGE, player_stats)

		if i < BULLET_COUNT - 1:
			await _wait(shooter, DELAY)

	_burst_active = false
