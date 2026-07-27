class_name ShotgunShotStrategy
extends ShootingStrategy

const PELLET_COUNT := 9
const SPREAD_DEG := 45.0
const DAMAGE := 5


func execute(
	shooter: Node2D,
	target: Node2D,
	_item: FactoryItem,
	player_stats: PlayerStats = null,
) -> void:
	if not is_instance_valid(target):
		return

	var base_dir := (target.global_position - shooter.global_position).normalized()
	var spread_rad := deg_to_rad(SPREAD_DEG)

	for i in PELLET_COUNT:
		var angle_offset := randf_range(-spread_rad * 0.5, spread_rad * 0.5)
		var dir := base_dir.rotated(angle_offset)
		var speed := 600.0 * randf_range(0.75, 1.25)

		spawn_bullet(shooter, dir, speed, DAMAGE, player_stats)
