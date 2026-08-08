class_name RifleShotStrategy
extends ShootingStrategy

const BURST_COUNT := 3
const DAMAGE := 10
const SPREAD_DEG := 5.0
const DELAY := 0.1
const SPEED := 600.0
const BULLET_SCENE := preload("res://objects/projectiles/bullet_rifle.tscn")

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

	for i in BURST_COUNT:
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

		spawn_bullet(BULLET_SCENE, shooter, dir, SPEED, DAMAGE, player_stats)

		if i < BURST_COUNT - 1:
			await _wait(shooter, DELAY)

	_burst_active = false
