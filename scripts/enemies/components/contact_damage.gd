class_name ContactDamage
extends Node

@export var damage: float = 1.0
@export var cooldown: float = 0.5

var _timer: float = 0.0


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	_timer = maxf(_timer - delta, 0.0)
	var enemy := get_parent() as BaseEnemy
	if enemy == null:
		return
	if _timer > 0.0:
		return
	for i in enemy.get_slide_collision_count():
		var col := enemy.get_slide_collision(i)
		if col.get_collider() is Player:
			_timer = cooldown
			col.get_collider().take_damage(damage)
			return
