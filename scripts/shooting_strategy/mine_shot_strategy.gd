class_name MineShotStrategy
extends ShootingStrategy

const DAMAGE := 20
const BLAST_RADIUS := 48.0
const MINE_SCENE := preload("res://objects/projectiles/mine.tscn")


func execute(
		shooter: Node2D,
		_target: Node2D,
		_item: FactoryItem,
		player_stats: PlayerStats = null,
) -> void:
	if not is_instance_valid(shooter):
		return

	var mine := MINE_SCENE.instantiate() as Mine
	mine.shooter = shooter
	mine.player_stats = player_stats
	mine.damage = DAMAGE
	mine.blast_radius = BLAST_RADIUS
	mine.global_position = shooter.global_position
	shooter.get_parent().add_child(mine)
