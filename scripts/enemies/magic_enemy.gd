class_name MagicEnemy
extends CharacterBody2D

@export var health: float = 3.0
@export var speed: float = 40.0
@export var slow_radius: float = 250.0
@export var contact_damage: float = 1.0
@export var coin_drop_min: int = 2
@export var coin_drop_max: int = 4

var _player: Node2D
var _gun: Node2D
var _hit_flash_timer: float = 0.0
var _contact_timer: float = 0.0
var _debuff_applied: bool = false

const CONTACT_COOLDOWN := 0.5

const COIN_PICKUP := preload("res://coin_pickup.tscn")


func _ready() -> void:
	for child in get_tree().root.get_children():
		_find_player(child)


func _find_player(node: Node) -> bool:
	if node is Player:
		_player = node
		_gun = node.get_node_or_null("Gun")
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

	if dist > slow_radius * 0.7:
		velocity = dir.normalized() * speed
	else:
		var strafe := Vector2(dir.y, -dir.x).normalized()
		var side := 1 if int(floori(dist * 0.1)) % 2 == 0 else -1
		velocity = strafe * speed * side + dir.normalized() * speed * 0.3

	move_and_slide()

	_contact_timer = maxf(_contact_timer - delta, 0.0)
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is Player and _contact_timer <= 0.0:
			_contact_timer = CONTACT_COOLDOWN
			col.get_collider().take_damage(contact_damage)

	if not _debuff_applied and dist <= slow_radius and _gun != null and _gun.has_method(&"apply_slow"):
		_gun.apply_slow()
		_debuff_applied = true
	elif _debuff_applied and dist > slow_radius and _gun != null and _gun.has_method(&"remove_slow"):
		_gun.remove_slow()
		_debuff_applied = false


func _exit_tree() -> void:
	if _debuff_applied and _gun != null and _gun.has_method(&"remove_slow"):
		_gun.remove_slow()


func hit(stats: Dictionary) -> void:
	var damage: float = stats.get("damage", 1.0) + stats.get("damage_bonus", 0.0)
	health -= damage
	_hit_flash_timer = 0.15
	if health <= 0.0:
		_die()


func _die() -> void:
	if _debuff_applied and _gun != null and _gun.has_method(&"remove_slow"):
		_gun.remove_slow()
		_debuff_applied = false
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
