class_name BaseEnemy
extends Area2D

## Set by [EnemyInfo] when being spawned by [GameSupervisor].
signal on_death
signal status_effect_applied(effect_name: StringName)
signal status_effect_removed(effect_name: StringName)

enum EnemyType { REGULAR, BOSS }

const MAX_PUSH_SPEED := 80.0

@export var enemy_type: EnemyType = EnemyType.REGULAR
@export var speed := 20.0
@export var health := 30
@export var damage_multiplier := 1.0
## Distance kept from other enemies while their bodies overlap.
@export var separation_radius := 12.0
## How strongly enemies are pushed away from each other while overlapping.
@export var separation_strength := 60.0
## Ring used to teleport a boss back into range when it strays too far.
@export var spawn_distance_min := 250.0
@export var spawn_distance_max := 400.0

var player: Node2D
var game_world: Node
var xp_amount: int
var _dead: bool
var status_effects: Dictionary[StringName, StatusEffect] = {}
var speed_multiplier: float = 1.0
var damage_taken_multiplier: float = 1.0


func _ready() -> void:
	add_to_group("enemy")


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	global_position += (dir * speed * speed_multiplier + _push_away()) * delta

	var expired_keys: Array[StringName] = []
	for key in status_effects:
		var effect: StatusEffect = status_effects[key]
		effect.update(delta, self)
		if effect.is_expired():
			expired_keys.append(key)
	for key in expired_keys:
		remove_status_effect(key)


func die_silently() -> void:
	_dead = true
	_remove_all_status_effects()
	queue_free()


func add_status_effect(effect: StatusEffect) -> void:
	var key := effect.effect_name
	if key in status_effects:
		status_effects[key].add_stack()
	else:
		effect.stack_count = 1
		effect.remaining_time = effect.duration
		status_effects[key] = effect
		effect.on_afflict(self)
		status_effect_applied.emit(key)


func remove_status_effect(effect_name: StringName) -> void:
	if effect_name not in status_effects:
		return
	var effect: StatusEffect = status_effects[effect_name]
	effect.on_remove(self)
	status_effects.erase(effect_name)
	status_effect_removed.emit(effect_name)


func has_status_effect(effect_name: StringName) -> bool:
	return effect_name in status_effects


func get_status_effect(effect_name: StringName) -> StatusEffect:
	return status_effects.get(effect_name)


func _remove_all_status_effects() -> void:
	for key in status_effects:
		status_effects[key].on_remove(self)
		status_effect_removed.emit(key)
	status_effects.clear()
	speed_multiplier = 1.0
	damage_taken_multiplier = 1.0


func take_damage(amount: int, ammo_type: StringName = &"", crit: bool = false) -> void:
	if _dead:
		return
	var final_amount := ceili(amount * damage_taken_multiplier)
	health -= final_amount
	var enemy_type_name := StringName(get_class())
	SignalBus.damage_dealt.emit(final_amount, ammo_type, enemy_type_name, crit)
	DamageNumberPool.show(final_amount, crit, global_position + Vector2(0, -16))
	if health <= 0:
		_dead = true
		_remove_all_status_effects()
		on_death.emit()
		SignalBus.enemy_killed.emit(StringName(EnemyType.keys()[enemy_type]))
		call_deferred("queue_free")


## Queries the physics server for overlapping [Area2D]s and pushes away from
## any other enemy found. Enemies are areas, so they never block each other;
## separation comes entirely from this force.
func _push_away() -> Vector2:
	var push := Vector2.ZERO
	for area: Area2D in get_overlapping_areas():
		if area is not BaseEnemy:
			continue
		var other := area
		var diff := global_position - other.global_position
		var dist := diff.length()
		if dist < 0.001:
			diff = Vector2.RIGHT.rotated(randf() * TAU)
			dist = 1.0
		var overlap := maxf(separation_radius + other.separation_radius - dist, 0.0)
		push += diff / dist * minf(overlap * separation_strength, MAX_PUSH_SPEED)
	return push
