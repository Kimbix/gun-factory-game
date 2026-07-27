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
	stats[&"xp_gain"] = Stat.new(data.xp_gain)
	stats[&"gold_gain"] = Stat.new(data.gold_gain)
	stats[&"armor"] = Stat.new(data.armor)
	stats[&"luck"] = Stat.new(data.luck)
	stats[&"crit_chance"] = Stat.new(data.crit_chance)
	stats[&"crit_damage"] = Stat.new(data.crit_damage)
	stats[&"difficulty"] = Stat.new(data.difficulty)
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
