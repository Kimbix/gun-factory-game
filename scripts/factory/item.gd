class_name Item
extends RefCounted
## A discrete item traveling through the factory. Carries its material id + mutable stats.

var material_id: StringName
var stats: Dictionary
## Cell this item visually leaves from this tick. Set by Grid.tick() before any push.
var from_cell: Vector2i = Vector2i.ZERO


func _init(p_material: StringName = &"", p_stats: Dictionary = { }) -> void:
	material_id = p_material
	stats = p_stats.duplicate()


func _to_string() -> String:
	return "Item(%s, %s)" % [material_id, stats]
