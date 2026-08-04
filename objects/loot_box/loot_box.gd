class_name LootBox
extends StaticBody2D
## A hittable, intangible container placed in the world.
##
## Player attacks deal damage to it through [method take_damage]. It lives on
## the 2D physics layer named "Destructible" (defined in project.godot) and
## does not actively check collisions (mask = 0), so the player and enemies
## pass through it. Player bullets' collision_mask includes the Destructible
## layer, which is how they reach this body.
##
## When [member max_health] reaches 0, [member drop_count] items are picked
## from [member loot_table] (a [LootBoxTable] of weighted [LootBoxEntry]s) and
## instantiated at a random angle within [member drop_radius] from the box.

@export var max_health: int = 3
@export var loot_table: LootBoxTable
@export var drop_count: int = 1
@export var drop_radius: float = 16.0

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
	_drop_loot()
	queue_free()


func _drop_loot() -> void:
	if loot_table == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	var origin := global_position
	for i: int in drop_count:
		var scene := loot_table.pick()
		if scene == null:
			continue
		var item := scene.instantiate()
		var offset := Vector2.RIGHT.rotated(randf() * TAU) * randf() * drop_radius
		item.global_position = origin + offset
		parent.call_deferred(&"add_child", item)
