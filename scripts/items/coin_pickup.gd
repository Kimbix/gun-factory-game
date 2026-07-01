class_name CoinPickup
extends Node2D

@export var value: int = 1

var _attracted: bool = false
var _player: Node2D


func _ready() -> void:
	var area: Area2D = $PickupArea
	if area != null:
		area.area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if _attracted:
		return
	var player := area.get_parent() as Player
	if player == null:
		return
	_attracted = true
	_player = player


func _process(delta: float) -> void:
	if not _attracted or _player == null:
		return
	var dir := _player.global_position - global_position
	var dist := dir.length()
	if dist < 4.0:
		_player.coins += value
		queue_free()
		return
	global_position += dir.normalized() * 200.0 * delta
