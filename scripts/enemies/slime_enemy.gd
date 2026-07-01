class_name SlimeEnemy
extends CharacterBody2D

@export var health: float = 4.0
@export var speed: float = 50.0
@export var contact_damage: float = 1.0
@export var fire_interval: float = 1.5
@export var coin_drop_min: int = 2
@export var coin_drop_max: int = 4

var _player: Node2D
var _hit_flash_timer: float = 0.0
var _contact_timer: float = 0.0
var _direction_timer: float = 0.0
var _fire_timer: float = 0.0
var _move_dir: Vector2

const CONTACT_COOLDOWN := 0.5
const DIRECTION_CHANGE := 2.0
const SLIME_FIRE := preload("res://slime_fire.tscn")
const COIN_PICKUP := preload("res://coin_pickup.tscn")


func _ready() -> void:
	for child in get_tree().root.get_children():
		_find_player(child)
	_change_direction()


func _find_player(node: Node) -> bool:
	if node is Player:
		_player = node
		return true
	for child in node.get_children():
		if _find_player(child):
			return true
	return false


func _change_direction() -> void:
	var angle := randf_range(0.0, TAU)
	_move_dir = Vector2(cos(angle), sin(angle))


func _physics_process(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		modulate = Color.WHITE.lerp(Color.RED, _hit_flash_timer / 0.15)
	elif modulate != Color.WHITE:
		modulate = Color.WHITE

	_contact_timer = maxf(_contact_timer - delta, 0.0)
	_fire_timer -= delta
	_direction_timer -= delta

	if _direction_timer <= 0.0:
		_direction_timer = DIRECTION_CHANGE + randf_range(-0.5, 0.5)
		_change_direction()

	velocity = _move_dir * speed
	move_and_slide()

	if _move_dir.length() > 0.0 and get_slide_collision_count() > 0:
		_move_dir = -_move_dir

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is Player and _contact_timer <= 0.0:
			_contact_timer = CONTACT_COOLDOWN
			col.get_collider().take_damage(contact_damage)

	if _fire_timer <= 0.0:
		_fire_timer = fire_interval + randf_range(-0.3, 0.3)
		_drop_fire()


func _drop_fire() -> void:
	var fire := SLIME_FIRE.instantiate()
	fire.position = position
	var parent := get_parent()
	if parent != null:
		parent.add_child(fire)
	else:
		get_tree().current_scene.add_child(fire)


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
