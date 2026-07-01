class_name BaseEnemy
extends CharacterBody2D

signal died
signal was_hit(amount: float)

@export var max_health: float = 3.0

var health: float
var player: Node2D
var _hit_flash_timer: float = 0.0


func _ready() -> void:
	health = max_health
	_find_player()


func _find_player() -> void:
	for child in get_tree().root.get_children():
		if _search_player(child):
			return


func _search_player(node: Node) -> bool:
	if node is Player:
		player = node
		return true
	for child in node.get_children():
		if _search_player(child):
			return true
	return false


func hit(stats: Dictionary) -> void:
	var dmg: float = stats.get("damage", 1.0) + stats.get("damage_bonus", 0.0)
	health -= dmg
	_hit_flash_timer = 0.15
	was_hit.emit(dmg)
	if health <= 0.0:
		call_deferred(&"_die")


func _die() -> void:
	died.emit()
	queue_free()


func _update_hit_flash(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		modulate = Color.WHITE.lerp(Color.RED, _hit_flash_timer / 0.15)
	elif modulate != Color.WHITE:
		modulate = Color.WHITE
