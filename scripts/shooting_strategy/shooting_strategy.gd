class_name ShootingStrategy
extends RefCounted

static func spawn_bullet(
		bullet_scene: PackedScene,
		shooter: Node2D,
		dir: Vector2,
		speed: float,
		damage: int,
		player_stats: PlayerStats = null,
) -> Bullet:
	var bullet := bullet_scene.instantiate()
	bullet.shooter = shooter
	bullet.player_stats = player_stats
	bullet.direction = dir
	bullet.global_position = shooter.global_position
	bullet.speed = speed
	bullet.damage = damage
	shooter.get_parent().add_child(bullet)
	return bullet


func execute(
		_shooter: Node2D,
		_target: Node2D,
		_item: FactoryItem,
		_player_stats: PlayerStats = null,
) -> void:
	pass
