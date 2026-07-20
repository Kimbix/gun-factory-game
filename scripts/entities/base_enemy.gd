class_name BaseEnemy
extends CharacterBody2D

enum EnemyType { REGULAR, BOSS }

@export var enemy_type: EnemyType = EnemyType.REGULAR
@export var spawn_distance_min: float = 250.0
@export var spawn_distance_max: float = 400.0

var player: Node2D


func _ready() -> void:
	add_to_group("enemy")
