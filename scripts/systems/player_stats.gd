class_name PlayerStats
extends RefCounted

var stats: Dictionary = { }
var health: float


func _init(data: PlayerStatsData) -> void:
	stats[&"max_health"] = Stat.new(data.max_health)
	stats[&"move_speed"] = Stat.new(data.move_speed)
	var ts := Stat.new(data.tick_speed)
	ts.diminishing_asymptote = 0.001
	ts.use_diminishing = true
	stats[&"tick_speed"] = ts
	stats[&"health_regen"] = Stat.new(data.health_regen)
	stats[&"pickup_range"] = Stat.new(data.pickup_range)
	stats[&"xp_gain"] = Stat.new(data.xp_gain)
	stats[&"gold_gain"] = Stat.new(data.gold_gain)
	var ar := Stat.new(data.armor)
	ar.diminishing_asymptote = 1.0
	ar.use_diminishing = true
	stats[&"armor"] = ar
	stats[&"luck"] = Stat.new(data.luck)
	stats[&"crit_chance"] = Stat.new(data.crit_chance)
	stats[&"crit_damage"] = Stat.new(data.crit_damage)
	stats[&"difficulty"] = Stat.new(data.difficulty)
	stats[&"invincibility_duration"] = Stat.new(data.invincibility_duration)
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
