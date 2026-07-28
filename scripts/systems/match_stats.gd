class_name MatchStats
extends RefCounted

## Combat — Damage
var total_damage_dealt: float
var damage_by_ammo_type: Dictionary[String, float]
var damage_by_enemy_type: Dictionary[String, float]
var critical_hits_landed: int
var critical_damage_dealt: float
var total_damage_taken: float
var damage_taken_by_enemy_type: Dictionary[String, float]
var total_healing_done: float
var healing_by_source: Dictionary[String, float]

## Combat — Kills
var total_enemies_killed: int
var enemies_killed_by_type: Dictionary[String, int]

## Economy
var gold_earned_total: int
var gold_earned_base: int
var xp_earned_total: int
var xp_earned_base: int

## Player Stats Snapshot
var final_level: int
var max_health: float
var move_speed: float
var armor: float
var crit_chance: float
var crit_damage: float
var health_regen: float
var tick_speed: float
var pickup_range: float
var luck: float
var xp_gain: float
var gold_gain: float
var difficulty: float

## Economy & Building
var buildings_placed: int
var ammo_crafted: int
var pillars_collected: int

## Match Context
var time_survived: float
var waves_completed: int
var difficulty_multiplier: float


func reset() -> void:
	total_damage_dealt = 0.0
	damage_by_ammo_type.clear()
	damage_by_enemy_type.clear()
	critical_hits_landed = 0
	critical_damage_dealt = 0.0
	total_damage_taken = 0.0
	damage_taken_by_enemy_type.clear()
	total_healing_done = 0.0
	healing_by_source.clear()
	total_enemies_killed = 0
	enemies_killed_by_type.clear()
	gold_earned_total = 0
	gold_earned_base = 0
	xp_earned_total = 0
	xp_earned_base = 0
	final_level = 0
	max_health = 0.0
	move_speed = 0.0
	armor = 0.0
	crit_chance = 0.0
	crit_damage = 0.0
	health_regen = 0.0
	tick_speed = 0.0
	pickup_range = 0.0
	luck = 0.0
	xp_gain = 0.0
	gold_gain = 0.0
	difficulty = 0.0
	buildings_placed = 0
	ammo_crafted = 0
	pillars_collected = 0
	time_survived = 0.0
	waves_completed = 0
	difficulty_multiplier = 0.0
