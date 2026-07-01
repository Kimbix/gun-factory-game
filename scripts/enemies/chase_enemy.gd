class_name ChaseEnemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var health: float = 3.0
@export var contact_damage: float = 1.0
@export var coin_drop_min: int = 2
@export var coin_drop_max: int = 4

var _player: Node2D
var _hit_flash_timer: float = 0.0
var _contact_timer: float = 0.0

const COIN_PICKUP := preload("res://coin_pickup.tscn")
const CONTACT_COOLDOWN := 0.5


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

	_contact_timer = maxf(_contact_timer - delta, 0.0)

	if _player == null:
		return

	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is Player:
			_apply_contact_damage()


func hit(stats: Dictionary) -> void:
	var damage: float = stats.get("damage", 1.0) + stats.get("damage_bonus", 0.0)
	health -= damage
	_hit_flash_timer = 0.15
	if health <= 0.0:
		_die()


func _die() -> void:
	for i in randi_range(coin_drop_min, coin_drop_max):
		var coin := COIN_PICKUP.instantiate()
		coin.position = position + Vector2(randi_range(-8, 8), randi_range(-8, 8))
		get_parent().add_child(coin)
	queue_free()


func _apply_contact_damage() -> void:
	if _contact_timer > 0.0:
		return
	_contact_timer = CONTACT_COOLDOWN
	if _player != null and _player.has_method(&"take_damage"):
		_player.take_damage(contact_damage)
