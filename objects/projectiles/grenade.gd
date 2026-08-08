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
	var enemy := _resolve_enemy(area)
	if enemy != null:
		_explode()


func _explode() -> void:
	if _fired:
		return
	_fired = true

	var enemies := get_tree().get_nodes_in_group(&"enemy")
	for enemy in enemies:
		if not enemy.has_method(&"take_damage"):
			continue
		var distance := global_position.distance_to(enemy.global_position)
		if distance <= blast_radius:
			var was_crit := false
			var final_damage := damage
			if player_stats != null and randf() < player_stats.stats[&"crit_chance"].value:
				was_crit = true
				var bonus: float = player_stats.stats[&"crit_damage"].value
				final_damage = ceili(damage * (1.0 + bonus))
			enemy.take_damage(final_damage)
			var enemy_type := &"unknown"
			if enemy is BaseEnemy:
				enemy_type = StringName(enemy.get_class())
			SignalBus.damage_dealt.emit(final_damage, &"grenade", enemy_type, was_crit)

			var dn := DamageNumberPool.create()
			var color := Color.YELLOW
			if was_crit:
				color = Color(0.9, 0.15, 0.05)
			var text := str(final_damage) + ("!" if was_crit else "")
			dn.play(text, color, enemy.global_position + Vector2(0, -16))

	var effect := EXPLOSION_EFFECT.instantiate()
	effect.global_position = global_position
	get_parent().add_child(effect)

	queue_free()


func _resolve_enemy(area: Area2D) -> BaseEnemy:
	if area is BaseEnemy:
		return area
	var parent := area.get_parent()
	if parent is BaseEnemy:
		return parent
	return null
