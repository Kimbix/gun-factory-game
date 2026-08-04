class_name MagnetItem
extends Area2D
## A pickup that, when collected, pulls every [ExperienceCrystal] currently
## on the floor toward the player as if it had been picked up. Mirrors the
## [ExperienceCrystal] flow: the player detects it through their
## [code]MagnetAttractionArea[/code] and calls [method start_follow]; once
## the magnet reaches the player it fires [signal collected] and triggers
## the crystal-pull effect.

signal collected

@export var speed: float = 400.0

var _player: Node2D = null


func start_follow(player: Node2D) -> void:
	_player = player


func _physics_process(delta: float) -> void:
	if _player == null:
		return

	global_position = global_position.move_toward(_player.global_position, speed * delta)

	if global_position.distance_squared_to(_player.global_position) < 16.0:
		_collect()


func _collect() -> void:
	for crystal in ExperienceCrystal.active_crystals:
		if is_instance_valid(crystal):
			crystal.start_follow(_player)
	collected.emit()
	queue_free()
