class_name RifleShotStrategy
extends ShootingStrategy

const BURST_COUNT := 3
const DAMAGE := 10
const SPREAD_DEG := 5.0
const DELAY := 0.1
const SPEED := 600.0


func execute(
		shooter: Node2D,
		target: Node2D,
		_item: FactoryItem,
		player_stats: PlayerStats = null,
) -> void:
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for i in BURST_COUNT:
		if not is_instance_valid(target):
			target = shooter.find_target()
			if target == null:
				return

		var base_dir := (target.global_position - shooter.global_position).normalized()
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)

		spawn_bullet(shooter, dir, SPEED, DAMAGE, player_stats)

		await shooter.get_tree().create_timer(DELAY).timeout
