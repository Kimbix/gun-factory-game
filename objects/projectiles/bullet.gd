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


func _get_ammo_type() -> StringName:
	return &""


func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime += delta
	if _lifetime >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.has_method(&"take_damage"):
		_deal_damage(body)


func _on_area_entered(area: Area2D) -> void:
	var enemy := _resolve_enemy(area)
	if enemy != null:
		_deal_damage(enemy)


func _deal_damage(target: Node2D) -> void:
	if _fired:
		return
	_fired = true
	var was_crit := false
	var final_damage := damage
	if player_stats != null and randf() < player_stats.stats[&"crit_chance"].value:
		was_crit = true
		var bonus: float = player_stats.stats[&"crit_damage"].value
		final_damage = ceili(damage * (1.0 + bonus))
	var enemy_type := &"unknown"
	var enemy := target as BaseEnemy
	if enemy != null:
		enemy_type = StringName(enemy.get_class())
	target.take_damage(final_damage)
	SignalBus.damage_dealt.emit(final_damage, _get_ammo_type(), enemy_type, was_crit)

	var dn := DamageNumberPool.create()
	var color := Color.YELLOW
	if was_crit:
		color = Color(0.9, 0.15, 0.05)
	var text := str(final_damage) + ("!" if was_crit else "")
	dn.play(text, color, target.global_position + Vector2(0, -16))

	queue_free()


func _resolve_enemy(area: Area2D) -> BaseEnemy:
	if area is BaseEnemy:
		return area
	var parent := area.get_parent()
	if parent is BaseEnemy:
		return parent
	return null
