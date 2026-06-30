class_name Projectile
extends Node2D
## A fired round traveling in a direction. Carries the round's stat_block for later use.

@export var speed: float = 200.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var stats: Dictionary = {}

var _sprite: Sprite2D
var _timer: float = 0.0
var _hitbox: Area2D
const BULLET_TEXTURE_UID := "uid://cy3t8hunvkjd8"


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load(BULLET_TEXTURE_UID)
	add_child(_sprite)

	_hitbox = Area2D.new()
	_hitbox.collision_mask = 2
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(4, 4)
	_hitbox.add_child(shape)
	add_child(_hitbox)
	_hitbox.body_entered.connect(_on_hit)


func setup(p_direction: Vector2, p_stats: Dictionary = {}, p_base_speed: float = 200.0, p_lifetime: float = 2.0) -> void:
	direction = p_direction.normalized()
	stats = p_stats
	rotation = direction.angle()
	speed = p_base_speed * stats.get("speed_mod", 1.0)
	lifetime = p_lifetime


func _process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()


func _on_hit(body: Node) -> void:
	if body.has_method(&"hit"):
		body.hit(stats)
	queue_free()