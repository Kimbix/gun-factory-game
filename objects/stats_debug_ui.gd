class_name StatsDebugUI
extends VBoxContainer

var _player: SimpleCharacter
var _elapsed: float

@onready var _level_label := $Level
@onready var _xp_label := $XP
@onready var _health_label := $Health
@onready var _max_health_label := $MaxHealth
@onready var _move_speed_label := $MoveSpeed
@onready var _tick_speed_label := $TickSpeed
@onready var _health_regen_label := $HealthRegen
@onready var _pickup_range_label := $PickupRange


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
	_health_label.text = "Health: %.1f" % player.health
	_max_health_label.text = "Max Health: %.1f" % stats.stats[&"max_health"].value
	_move_speed_label.text = "Move Speed: %.1f" % stats.stats[&"move_speed"].value
	_tick_speed_label.text = "Tick Speed: %.4f" % stats.stats[&"tick_speed"].value
	_health_regen_label.text = "Health Regen: %.1f/s" % stats.stats[&"health_regen"].value
	_pickup_range_label.text = "Pickup Range: %.1f" % stats.stats[&"pickup_range"].value
