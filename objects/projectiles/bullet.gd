class_name Bullet
extends Area2D

const LIFETIME := 3.0

var speed := 400.0
var direction: Vector2
var damage := 5
var shooter: Node2D
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
	if body == shooter:
		return
	var final_damage := damage
	var player := shooter as SimpleCharacter
	if player:
		var stats := player.player_stats
		if randf() < stats.stats[&"crit_chance"].value:
			var bonus: float = stats.stats[&"crit_damage"].value
			final_damage = ceili(damage * (1.0 + bonus))
	body.take_damage(final_damage)
	queue_free()
