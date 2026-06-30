class_name Projectile
extends Node2D
## A fired round traveling in a direction. Carries the round's stat_block for later use.

@export var speed: float = 200.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var stats: Dictionary = {}

var _sprite: Sprite2D
var _timer: float = 0.0
const BULLET_TEXTURE_UID := "uid://cy3t8hunvkjd8"


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load(BULLET_TEXTURE_UID)
	add_child(_sprite)


func setup(p_direction: Vector2, p_stats: Dictionary = {}) -> void:
	direction = p_direction.normalized()
	stats = p_stats
	rotation = direction.angle()


func _process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()