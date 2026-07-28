class_name BaseEnemy
extends CharacterBody2D

## Set by [EnemyInfo] when being spawned by [GameSupervisor].
signal on_death

enum EnemyType { REGULAR, BOSS }

@export var enemy_type: EnemyType = EnemyType.REGULAR

var player: Node2D
var game_world: Node
@export var speed := 20.0
@export var health := 30
@export var damage_multiplier := 1.0
var xp_amount: int
var _dead: bool


func die_silently() -> void:
	_dead = true
	queue_free()


func _ready() -> void:
	add_to_group("enemy")


func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_collide(velocity * _delta)


func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		_dead = true
		on_death.emit()
		queue_free()
