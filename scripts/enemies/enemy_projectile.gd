class_name EnemyProjectile
extends Area2D

@export var speed: float = 120.0
@export var lifetime: float = 3.0
@export var damage: float = 1.0

var _direction: Vector2
var _timer: float = 0.0


func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/projectiles/spr_shootEnemyProjectile.png")
	add_child(sprite)
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(6, 6)
	add_child(shape)
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_hit)


func setup(dir: Vector2) -> void:
	_direction = dir.normalized()
	rotation = _direction.angle()


func _process(delta: float) -> void:
	position += _direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()


func _on_hit(body: Node) -> void:
	if body.has_method(&"take_damage"):
		body.take_damage(damage)
	queue_free()
