class_name CoinPickup
extends Node2D

@export var value: int = 1

var _attracted: bool = false
var _player: Node2D
var _sprite: Sprite2D


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load("res://assets/world/spr_coin.png")
	add_child(_sprite)

	var area := Area2D.new()
	area.collision_layer = 8
	area.collision_mask = 1
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(8, 8)
	area.add_child(shape)
	add_child(area)
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
