class_name Chest
extends Node2D

@export var coin_min: int = 1
@export var coin_max: int = 5
@export var loot_table: Array[Dictionary] = []

var _opened: bool = false
var _sprite: Sprite2D
var _area: Area2D


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load("res://assets/world/spr_chest.png")
	add_child(_sprite)

	_area = Area2D.new()
	_area.collision_layer = 8
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(8, 8)
	_area.add_child(shape)
	add_child(_area)


func open() -> void:
	if _opened:
		return
	_opened = true
	var count := randi_range(coin_min, coin_max)
	for i in count:
		_spawn_coin()
	for entry in loot_table:
		var type := entry.get(&"type") as ComponentType
		if type == null:
			continue
		if randf() >= entry.get(&"chance", 1.0):
			continue
		var item_count: int = entry.get(&"count", 1)
		for j in item_count:
			_spawn_item(type)


func _spawn_coin() -> void:
	var coin := CoinPickup.new()
	coin.value = 1
	coin.position = global_position + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
	get_parent().add_child(coin)


func _spawn_item(type: ComponentType) -> void:
	var pickup := ItemPickup.new()
	pickup.component_type = type
	pickup.position = global_position + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
	get_parent().add_child(pickup)
