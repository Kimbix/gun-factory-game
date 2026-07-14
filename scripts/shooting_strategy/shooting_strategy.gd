class_name ShootingStrategy
extends RefCounted

const BULLET := preload("res://objects/bullet.tscn")


static func spawn_bullet(shooter: Node2D, dir: Vector2, speed: float, damage: int) -> Bullet:
	var bullet := BULLET.instantiate()
	bullet.direction = dir
	bullet.global_position = shooter.global_position
	bullet.speed = speed
	bullet.damage = damage
	shooter.get_parent().add_child(bullet)
	return bullet


func execute(_shooter: Node2D, _target: Node2D, _item: FactoryItem) -> void:
	pass
