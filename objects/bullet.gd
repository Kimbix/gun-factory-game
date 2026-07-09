extends Area2D

const BULLET_TEXTURE := preload("res://assets/world_entities/spr_projectileBullet.png")
const SPEED := 400.0
const LIFETIME := 3.0

var direction: Vector2
var _lifetime := 0.0


func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = BULLET_TEXTURE
	add_child(sprite)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	_lifetime += delta
	if _lifetime >= LIFETIME:
		queue_free()
