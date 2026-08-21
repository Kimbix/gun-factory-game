class_name Bullet
extends Area2D

const LIFETIME := 3.0

var speed := 400.0
var direction: Vector2
var damage := 5
var shooter: Node2D
var player_stats: PlayerStats
var _lifetime := 0.0
var _fired := false


func _ready() -> void:
	rotation = direction.angle()
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime += delta
	if _lifetime >= LIFETIME:
		queue_free()


func _get_ammo_type() -> StringName:
	return &""


func _on_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area) or not area.has_method(&"take_damage"):
		return
	_deal_damage(area)


func _deal_damage(target: Node2D) -> void:
	if _fired:
		return
	_fired = true
	var roll := DamageUtil.roll_crit(damage, player_stats)
	if target is BaseEnemy:
		target.take_damage(roll.damage, _get_ammo_type(), roll.crit)
	else:
		target.take_damage(roll.damage)
	queue_free()
