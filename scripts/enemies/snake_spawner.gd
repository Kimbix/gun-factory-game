class_name SnakeSpawner
extends BaseEnemy

@export var spawn_interval: float = 4.0
@export var spawn_radius: float = 32.0
@export var max_alive_snakes: int = 3

var _spawn_timer: float = 0.0
var _snakes: Array[Node] = []

const SNAKE := preload("res://snake_enemy.tscn")


func _ready() -> void:
	super()
	max_health = 5.0
	health = max_health
	_spawn_timer = spawn_interval


func _physics_process(delta: float) -> void:
	_update_hit_flash(delta)

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
