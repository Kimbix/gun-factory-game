class_name SlimeFire
extends Area2D

@export var damage: float = 0.5
@export var lifetime: float = 5.0

var _timer: float = 0.0
var _contact_timer: float = 0.0
@onready var _sprite: Sprite2D = $Sprite2D

const CONTACT_COOLDOWN := 0.5


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_sprite.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.3)


func _process(delta: float) -> void:
	_timer += delta
	_contact_timer = maxf(_contact_timer - delta, 0.0)
	var remaining := lifetime - _timer
	if remaining < 1.0:
		_sprite.modulate.a = maxf(remaining, 0.0)
	if _timer >= lifetime:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _contact_timer > 0.0:
		return
	if body.has_method(&"take_damage"):
		body.take_damage(damage)
		_contact_timer = CONTACT_COOLDOWN
