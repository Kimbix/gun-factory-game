class_name Chest
extends Node2D

@export var loot_table: LootTable

var _opened: bool = false
var _area: Area2D

const ITEM_SCENE := preload("res://item_pickup.tscn")


func _ready() -> void:
	if not has_node(NodePath("Sprite2D")):
		var s := Sprite2D.new()
		s.name = &"Sprite2D"
		s.texture = load("res://assets/world/spr_chest.png")
		add_child(s)
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
	visible = false
	_area.queue_free()

	if loot_table == null:
		return
	var count := randi_range(loot_table.drop_min, loot_table.drop_max)
	for i in count:
		_spawn_random_entry()


func _spawn_random_entry() -> void:
	if loot_table.entries.is_empty():
		return
	var entry: LootTableEntry = loot_table.entries.pick_random()
	if entry.item_type == null:
		return
	if randf() >= entry.chance:
		return
	var count := randi_range(entry.min_count, entry.max_count)
	for j in count:
		var pickup: ItemPickup = ITEM_SCENE.instantiate()
		pickup.component_type = entry.item_type
		pickup.position = global_position + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
		get_parent().add_child(pickup)
