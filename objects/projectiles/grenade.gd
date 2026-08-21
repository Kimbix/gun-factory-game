class_name Grenade
extends Area2D

const DECELERATION := 150.0
const EXPLOSION_EFFECT := preload("res://objects/effects/explosion_effect.tscn")

var speed := 300.0
var direction: Vector2
var damage := 25
var blast_radius := 64.0
var shooter: Node2D
var player_stats: PlayerStats
var _fired := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if speed <= 0.0:
		_explode()
		return

	global_position += direction * speed * delta
	speed = maxf(speed - DECELERATION * delta, 0.0)


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.has_method(&"take_damage"):
		_explode()


func _on_area_entered(area: Area2D) -> void:
	if area is not BaseEnemy or not is_instance_valid(area):
		return
	_explode()


func _explode() -> void:
	if _fired:
		return
	_fired = true

	var roll := DamageUtil.roll_crit(damage, player_stats)
	var targets := get_tree().get_nodes_in_group(&"enemy")
	targets.append_array(get_tree().get_nodes_in_group(&"destructible"))
	for target in targets:
		if not target.has_method(&"take_damage"):
			continue
		var distance := global_position.distance_to(target.global_position)
		if distance <= blast_radius:
			if target is BaseEnemy:
				target.take_damage(roll.damage, &"grenade", roll.crit)
			else:
				target.take_damage(roll.damage)

	var effect := EXPLOSION_EFFECT.instantiate()
	effect.global_position = global_position
	get_parent().add_child(effect)

	queue_free()
