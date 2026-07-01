class_name ChaseEnemy
extends BaseEnemy

@export var speed: float = 60.0


func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
