class_name PlayerStatsData
extends Resource

## Maximum health that the player is allowed to have at once
@export var max_health: float = 100.0
## Movement speed of the player in units per second
@export var move_speed: float = 75.0
## Tick delay in seconds of the player's grid
@export var tick_speed: float = 0.05
## Amount of health recovered per second
@export var health_regen: float = 0.0
## Radius of the pickup range for dropped items
@export var pickup_range: float = 20.0
## Percentage of XP that is gained per crystal
@export var xp_gain: float = 1.0
## Percentage of gold that is gained per crystal
@export var gold_gain: float = 1.0
## Percentage reduction of received damage
@export var armor: float = 0.0
## Duration in seconds of invincibility after taking damage
@export var invincibility_duration: float = 0.1
## Increases the likelyhood of favorable events happening
@export var luck: float = 0.0
## Chance of a bullet dealing a critical hit
@export var crit_chance: float = 0.01
## Percentage of additional damage dealt when a hit is critical
@export var crit_damage: float = 1.0
## Speed, strength and amount of enemies spawned
@export var difficulty: float = 0.0
