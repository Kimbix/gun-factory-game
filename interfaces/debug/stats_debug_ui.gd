class_name StatsDebugUI
extends VBoxContainer

var _player: SimpleCharacter
var _elapsed: float

@onready var _level_label := $Level
@onready var _xp_label := $XP
@onready var _gold_label := $Gold
@onready var _health_label := $Health
@onready var _max_health_label := $MaxHealth
@onready var _move_speed_label := $MoveSpeed
@onready var _tick_speed_label := $TickSpeed
@onready var _health_regen_label := $HealthRegen
@onready var _pickup_range_label := $PickupRange
@onready var _xp_gain_label := $XPGain
@onready var _gold_gain_label := $GoldGain
@onready var _armor_label := $Armor
@onready var _luck_label := $Luck
@onready var _crit_chance_label := $CritChance
@onready var _crit_damage_label := $CritDamage
@onready var _difficulty_label := $Difficulty


func _process(delta: float) -> void:
	if not visible:
		return
	_elapsed += delta
	if _elapsed < 0.3:
		return
	_elapsed = 0.0
	if _player != null:
		refresh(_player)


func refresh(player: SimpleCharacter) -> void:
	_player = player
	var stats: PlayerStats = player.player_stats
	_level_label.text = "Level: %d" % player.level_system.level
	_xp_label.text = "XP: %d / %d" % [player.level_system.xp, player.level_system.xp_to_next_level]
	_gold_label.text = "Gold: %d" % player.level_system.gold
	_health_label.text = "Health: %.1f" % player.health
	_max_health_label.text = "Max Health: %.1f" % stats.stats[&"max_health"].value
	_move_speed_label.text = "Move Speed: %.1f" % stats.stats[&"move_speed"].value
	_tick_speed_label.text = "Tick Speed: %.4f" % stats.stats[&"tick_speed"].value
	_health_regen_label.text = "Health Regen: %.1f/s" % stats.stats[&"health_regen"].value
	_pickup_range_label.text = "Pickup Range: %.1f" % stats.stats[&"pickup_range"].value
	_xp_gain_label.text = "XP Gain: %.2f" % stats.stats[&"xp_gain"].value
	_gold_gain_label.text = "Gold Gain: %.2f" % stats.stats[&"gold_gain"].value
	var armor_val: float = stats.stats[&"armor"].value
	var reduction: float = armor_val / (armor_val + 0.5) * 100.0
	_armor_label.text = "Armor: %.2f (%.1f%% reduction)" % [armor_val, reduction]
	_luck_label.text = "Luck: %.2f" % stats.stats[&"luck"].value
	_crit_chance_label.text = "Crit Chance: %.0f%%" % (stats.stats[&"crit_chance"].value * 100.0)
	_crit_damage_label.text = "Crit Damage: +%.0f%%" % (stats.stats[&"crit_damage"].value * 100.0)
	_difficulty_label.text = "Difficulty: %.2f" % stats.stats[&"difficulty"].value
