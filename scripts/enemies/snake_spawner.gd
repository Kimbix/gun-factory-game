class_name SnakeSpawner
extends CharacterBody2D

@export var health: float = 5.0
@export var spawn_interval: float = 4.0
@export var spawn_radius: float = 32.0
@export var max_alive_snakes: int = 3
@export var coin_drop_min: int = 3
@export var coin_drop_max: int = 5

var _hit_flash_timer: float = 0.0
var _spawn_timer: float = 0.0
var _snakes: Array[Node] = []

const SNAKE := preload("res://snake_enemy.tscn")
const COIN_PICKUP := preload("res://coin_pickup.tscn")


func _ready() -> void:
	_spawn_timer = spawn_interval


func _physics_process(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		modulate = Color.WHITE.lerp(Color.RED, _hit_flash_timer / 0.15)
	elif modulate != Color.WHITE:
		modulate = Color.WHITE

	_snakes = _snakes.filter(func(n): return is_instance_valid(n) and n != null)
	_spawn_timer -= delta
	if _spawn_timer <= 0.0 and _snakes.size() < max_alive_snakes:
		_spawn_timer = spawn_interval
		_spawn_snake()


func _spawn_snake() -> void:
	var snake := SNAKE.instantiate()
	var offset := Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
	snake.position = position + offset
	var parent := get_parent()
	if parent != null:
		parent.add_child(snake)
	else:
		get_tree().current_scene.add_child(snake)
	_snakes.append(snake)


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
