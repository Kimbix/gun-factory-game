class_name EnemySlime
extends BaseEnemy

signal on_death

const SPEED := 20.0

var health := 30
var _dead: bool


func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_collide(velocity * _delta)


# TODO: This should not be on the slime's, should be base enemy's code
func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		_dead = true
		on_death.emit()
		queue_free()
