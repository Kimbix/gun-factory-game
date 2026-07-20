class_name BaseEnemy
extends CharacterBody2D

var player: Node2D
var game_world: Node


func _ready() -> void:
	add_to_group("enemy")
