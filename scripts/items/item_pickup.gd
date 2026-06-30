class_name ItemPickup
extends Node2D

@export var component_type: ComponentType:
	set(value):
		component_type = value
		_update_sprite()

var _sprite: Sprite2D
var _area: Area2D


func _ready() -> void:
	_sprite = Sprite2D.new()
	add_child(_sprite)
	_update_sprite()

	_area = Area2D.new()
	_area.collision_layer = 8
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(8, 8)
	_area.add_child(shape)
	add_child(_area)


func _update_sprite() -> void:
	if _sprite == null:
		return
	if component_type != null and component_type.sprite != null:
		_sprite.texture = component_type.sprite
	else:
		_sprite.texture = null
