class_name GrenadeShotStrategy
extends ShootingStrategy

const DAMAGE := 25
const BLAST_RADIUS := 64.0
const SPEED := 300.0
const GRENADE_SCENE := preload("res://objects/projectiles/grenade.tscn")


func execute(
		shooter: Node2D,
		target: Node2D,
		_item: FactoryItem,
		player_stats: PlayerStats = null,
) -> void:
	if not is_instance_valid(target):
		return

	var dir := (target.global_position - shooter.global_position).normalized()
	var grenade := GRENADE_SCENE.instantiate() as Grenade
	grenade.shooter = shooter
	grenade.player_stats = player_stats
	grenade.direction = dir
	grenade.global_position = shooter.global_position
	grenade.speed = SPEED
	grenade.damage = DAMAGE
	grenade.blast_radius = BLAST_RADIUS
	shooter.get_parent().add_child(grenade)
