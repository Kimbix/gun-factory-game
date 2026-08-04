class_name LootBox
extends StaticBody2D
## A hittable, intangible container placed in the world.
##
## Player attacks deal damage to it through [method take_damage]. It lives on
## the 2D physics layer named "Destructible" (defined in project.godot) and
## does not actively check collisions (mask = 0), so the player and enemies
## pass through it. Player bullets' collision_mask includes the Destructible
## layer, which is how they reach this body. When [member max_health] reaches
## 0 it is destroyed and a loot drop will be spawned (TODO).

@export var max_health: int = 3

var _health: int
var _dead: bool = false


func _ready() -> void:
	_health = max_health


func take_damage(amount: int) -> void:
	if _dead:
		return
	_health -= amount
	if _health <= 0:
		_die()


func _die() -> void:
	_dead = true
	# TODO: spawn loot drop
	queue_free()
