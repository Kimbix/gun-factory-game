class_name PlayerStats
extends RefCounted

var stats: Dictionary = { }
var health: float


func _init(data: PlayerStatsData) -> void:
	stats[&"max_health"] = Stat.new(data.max_health)
	stats[&"move_speed"] = Stat.new(data.move_speed)
	stats[&"tick_speed"] = Stat.new(data.tick_speed)
	stats[&"health_regen"] = Stat.new(data.health_regen)
	stats[&"pickup_range"] = Stat.new(data.pickup_range)
	health = data.max_health


func apply_modifier(source_id: StringName, stat_name: StringName, mod_value: float) -> void:
	var stat: Stat = stats.get(stat_name)
	if stat == null:
		return
	stat.apply_modifier(source_id, mod_value)


func remove_modifier(source_id: StringName, stat_name: StringName) -> void:
	var stat: Stat = stats.get(stat_name)
	if stat == null:
		return
	stat.remove_modifier(source_id)
