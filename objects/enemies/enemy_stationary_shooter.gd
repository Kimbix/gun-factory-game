class_name EnemyStationaryShooter
extends BaseEnemy

## Scene of the projectile fired at the player.
@export var projectile_scene: PackedScene
## Seconds between shots.
@export_range(0.1, 10.0) var shoot_interval := 2.0
## Speed of the fired projectile, in pixels per second.
@export var projectile_speed := 300.0
## Base damage of each projectile, scaled by [member BaseEnemy.damage_multiplier].
@export var projectile_damage := 10
## The shooter never moves, so it does not chase the player.

var _shoot_timer := 0.0


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	_shoot_timer -= delta
	if _shoot_timer > 0.0:
		return
	_shoot_timer = shoot_interval
	_shoot()


func _shoot() -> void:
	if projectile_scene == null:
		return
	var dir := (player.global_position - global_position).normalized()
	var proj := projectile_scene.instantiate() as EnemyProjectile
	if proj == null:
		return
	proj.direction = dir
	proj.speed = projectile_speed
	proj.damage = ceili(projectile_damage * damage_multiplier)
	proj.enemy_type = StringName(BaseEnemy.EnemyType.keys()[enemy_type])
	proj.global_position = global_position
	var parent := game_world if game_world != null else get_parent()
	if parent != null:
		parent.add_child(proj)
