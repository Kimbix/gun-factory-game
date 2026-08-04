class_name BaseEnemy
extends Area2D

## Set by [EnemyInfo] when being spawned by [GameSupervisor].
signal on_death

enum EnemyType { REGULAR, BOSS }

@export var enemy_type: EnemyType = EnemyType.REGULAR

var player: Node2D
var game_world: Node
@export var speed := 20.0
@export var health := 30
@export var damage_multiplier := 1.0
## Distance kept from other enemies while their bodies overlap.
@export var separation_radius := 12.0
## How strongly enemies are pushed away from each other while overlapping.
@export var separation_strength := 40.0
## Ring used to teleport a boss back into range when it strays too far.
@export var spawn_distance_min := 250.0
@export var spawn_distance_max := 400.0
const MAX_PUSH_SPEED := 20.0
var xp_amount: int
var _dead: bool


func die_silently() -> void:
	_dead = true
	queue_free()


func _ready() -> void:
	add_to_group("enemy")


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	global_position += (dir * speed + _push_away()) * delta


func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		_dead = true
		on_death.emit()
		SignalBus.enemy_killed.emit(StringName(EnemyType.keys()[enemy_type]))
		queue_free()


## Queries the physics server for overlapping [Area2D]s and pushes away from
## any other enemy found. Enemies are areas, so they never block each other;
## separation comes entirely from this force.
func _push_away() -> Vector2:
	var push := Vector2.ZERO
	for area: Area2D in get_overlapping_areas():
		var other := _resolve_enemy(area)
		if other == null or other == self:
			continue
		var diff := global_position - other.global_position
		var dist := diff.length()
		if dist < 0.001:
			diff = Vector2.RIGHT.rotated(randf() * TAU)
			dist = 1.0
		var overlap := maxf(separation_radius + other.separation_radius - dist, 0.0)
		push += diff / dist * minf(overlap * separation_strength, MAX_PUSH_SPEED)
	return push


## Maps an overlapping [Area2D] to the [BaseEnemy] it belongs to. Both the
## enemy root itself and its child [EnemyHitbox] resolve to the same enemy.
func _resolve_enemy(area: Area2D) -> BaseEnemy:
	if area is BaseEnemy:
		return area
	var parent := area.get_parent()
	if parent is BaseEnemy:
		return parent
	return null
