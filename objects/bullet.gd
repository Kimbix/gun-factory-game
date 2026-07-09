class_name Bullet
extends Area2D

const SPEED := 400.0
const LIFETIME := 3.0

var direction: Vector2
var _lifetime := 0.0


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	_lifetime += delta
	if _lifetime >= LIFETIME:
		queue_free()
