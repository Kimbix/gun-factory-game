class_name BaseEnemy
extends CharacterBody2D

var player: Node2D


func _ready() -> void:
	add_to_group("enemy")
