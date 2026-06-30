class_name Player
extends CharacterBody2D
## Top-down player character. WASD movement.

@export var speed: float = 100.0


func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis(&"move_left", &"move_right")
	dir.y = Input.get_axis(&"move_up", &"move_down")
	velocity = dir.normalized() * speed
	move_and_slide()