class_name HitFlash
extends Node

var _timer: float = 0.0


func _ready() -> void:
	var enemy := get_parent() as BaseEnemy
	if enemy != null:
		enemy.was_hit.connect(_on_hit)
		enemy.ready.connect(_sync_modulate, CONNECT_ONE_SHOT)


func _sync_modulate() -> void:
	var enemy := get_parent() as BaseEnemy
	if enemy != null and enemy.modulate != Color.WHITE:
		enemy.modulate = Color.WHITE


func _on_hit(_amount: float) -> void:
	_timer = 0.15


func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer -= delta
	var enemy := get_parent() as BaseEnemy
	if enemy == null:
		return
	enemy.modulate = Color.WHITE.lerp(Color.RED, _timer / 0.15)
	if _timer <= 0.0:
		enemy.modulate = Color.WHITE
