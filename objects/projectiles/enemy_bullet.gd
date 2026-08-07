class_name EnemyProjectile
extends Area2D

const LIFETIME := 10.0

var speed := 300.0
var direction := Vector2.RIGHT
var damage := 10
var enemy_type := &""
var _lifetime := 0.0

@onready var _notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	_notifier.screen_exited.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime += delta
	if _lifetime >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method(&"take_damage"):
		body.take_damage(damage, enemy_type)
	queue_free()
