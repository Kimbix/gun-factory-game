class_name ExperienceCrystal
extends Area2D

signal collected

@export var xp_value: int = 1

var _player: Node2D = null
var _speed: float = 300.0


func start_follow(player: Node2D) -> void:
	_player = player


func _physics_process(delta: float) -> void:
	if _player == null:
		return

	global_position = global_position.move_toward(_player.global_position, _speed * delta)

	if global_position.distance_squared_to(_player.global_position) < 16.0:
		collected.emit()
		queue_free()
