class_name SpawnCoinsOnDeath
extends Node

@export var min_coins: int = 2
@export var max_coins: int = 4

const COIN_PICKUP := preload("res://coin_pickup.tscn")


func _ready() -> void:
	var enemy := get_parent() as BaseEnemy
	if enemy != null:
		enemy.died.connect(_on_died)


func _on_died() -> void:
	var enemy := get_parent() as BaseEnemy
	if enemy == null:
		return
	var parent := enemy.get_parent()
	if parent == null:
		return
	var pos := enemy.position
	for i in randi_range(min_coins, max_coins):
		var coin := COIN_PICKUP.instantiate()
		coin.position = pos + Vector2(randi_range(-8, 8), randi_range(-8, 8))
		parent.add_child(coin)
