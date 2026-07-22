class_name Bullet
extends Area2D

const LIFETIME := 3.0

var speed := 400.0
var direction: Vector2
var damage := 5
var _lifetime := 0.0


func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime += delta
	if _lifetime >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if not body.has_method("take_damage"):
		return
	body.take_damage(damage)
	queue_free()
