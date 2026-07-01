class_name ShootEnemy
extends BaseEnemy

@export var speed: float = 30.0
@export var shoot_range: float = 200.0
@export var shoot_cooldown: float = 2.0
@export var projectile_speed: float = 120.0
@export var projectile_damage: float = 1.0

var _shoot_timer: float = 0.0


func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var dir := (player.global_position - global_position)
	var dist := dir.length()
	_shoot_timer -= delta

	if dist > shoot_range:
		velocity = dir.normalized() * speed
	elif dist < shoot_range * 0.4:
		velocity = -dir.normalized() * speed * 0.5
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if _shoot_timer <= 0.0 and dist <= shoot_range:
		_shoot_timer = shoot_cooldown
		_fire(dir.normalized())


func _fire(dir: Vector2) -> void:
	var proj := EnemyProjectile.new()
	proj.setup(dir)
	var world := get_tree().current_scene
	world.add_child(proj)
	proj.global_position = global_position
