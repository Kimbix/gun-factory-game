class_name SpreadShotStrategy
extends ShootingStrategy

const BULLET_COUNT := 15
const DAMAGE := 3
const SPREAD_DEG := 60.0
const DELAY := 0.05


func execute(
	shooter: Node2D,
	target: Node2D,
	_item: FactoryItem,
	player_stats: PlayerStats = null,
) -> void:
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for i in BULLET_COUNT:
		if not is_instance_valid(target):
			target = shooter.find_target()
			if target == null:
				return

		var base_dir := (target.global_position - shooter.global_position).normalized()
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)
		var speed := 600.0 * randf_range(0.95, 1.05)

		spawn_bullet(shooter, dir, speed, DAMAGE, player_stats)

		await shooter.get_tree().create_timer(DELAY).timeout
