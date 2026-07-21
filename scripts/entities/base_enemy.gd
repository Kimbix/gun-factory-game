class_name BaseEnemy
extends CharacterBody2D

enum EnemyType { REGULAR, BOSS }

@export var enemy_type: EnemyType = EnemyType.REGULAR

var player: Node2D
var game_world: Node

## Set by [EnemyInfo] when being spawned by [GameSupervisor].
var xp_amount: int


func _ready() -> void:
	add_to_group("enemy")
