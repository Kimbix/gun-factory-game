class_name EnemySlime
extends BaseEnemy

signal on_death

const SPEED := 60.0

var health := 30


func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_collide(velocity * _delta)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		on_death.emit()
		queue_free()
