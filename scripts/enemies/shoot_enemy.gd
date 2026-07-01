class_name ShootEnemy
extends CharacterBody2D

@export var health: float = 2.0
@export var speed: float = 30.0
@export var shoot_range: float = 200.0
@export var shoot_cooldown: float = 2.0
@export var projectile_speed: float = 120.0
@export var projectile_damage: float = 1.0
@export var coin_drop_min: int = 1
@export var coin_drop_max: int = 3

var _player: Node2D
var _hit_flash_timer: float = 0.0
var _shoot_timer: float = 0.0

const COIN_PICKUP := preload("res://coin_pickup.tscn")


func _ready() -> void:
	for child in get_tree().root.get_children():
		_find_player(child)


func _find_player(node: Node) -> bool:
	if node is Player:
		_player = node
		return true
	for child in node.get_children():
		if _find_player(child):
			return true
	return false


func _physics_process(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		modulate = Color.WHITE.lerp(Color.RED, _hit_flash_timer / 0.15)
	elif modulate != Color.WHITE:
		modulate = Color.WHITE

	if _player == null:
		return

	var dir := (_player.global_position - global_position)
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


func hit(stats: Dictionary) -> void:
	var damage: float = stats.get("damage", 1.0) + stats.get("damage_bonus", 0.0)
	health -= damage
	_hit_flash_timer = 0.15
	if health <= 0.0:
		_die()


func _die() -> void:
	call_deferred(&"_spawn_coins_and_free")


func _spawn_coins_and_free() -> void:
	var parent := get_parent()
	if parent == null:
		return
	for i in randi_range(coin_drop_min, coin_drop_max):
		var coin := COIN_PICKUP.instantiate()
		coin.position = position + Vector2(randi_range(-8, 8), randi_range(-8, 8))
		parent.add_child(coin)
	queue_free()
