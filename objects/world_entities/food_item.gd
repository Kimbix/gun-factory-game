class_name FoodItem
extends Area2D

signal collected

@export var source_name: StringName = &"generic_heal_item"
@export var recovered: float = 10.0
@export var speed: float = 400.0

var _player: SimpleCharacter = null


func _physics_process(delta: float) -> void:
	if _player == null:
		return

	global_position = global_position.move_toward(_player.global_position, speed * delta)

	if global_position.distance_squared_to(_player.global_position) < 16.0:
		_collect()


func start_follow(player: Node2D) -> void:
	_player = player


func _collect() -> void:
	_player.heal(recovered, source_name)
	collected.emit()
	queue_free()
