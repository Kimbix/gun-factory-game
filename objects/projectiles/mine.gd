class_name Mine
extends Node2D

const DETECTION_RANGE := 48.0
const MAX_MINES := 256
const EXPLOSION_EFFECT := preload("res://objects/effects/explosion_effect.tscn")

static var _active_mines: Array[Mine] = []

var damage := 20
var blast_radius := 48.0
var shooter: Node2D
var player_stats: PlayerStats
var _triggered := false


func _ready() -> void:
	_active_mines.append(self)
	if _active_mines.size() > MAX_MINES:
		_active_mines[0].die_silently()
		_active_mines.remove_at(0)

	var detection_area := Area2D.new()
	var detection_shape := CircleShape2D.new()
	detection_shape.radius = DETECTION_RANGE
	var collision := CollisionShape2D.new()
	collision.shape = detection_shape
	detection_area.add_child(collision)
	add_child(detection_area)
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.area_entered.connect(_on_area_entered)


func die_silently() -> void:
	_active_mines.erase(self)
	queue_free()


func _exit_tree() -> void:
	_active_mines.erase(self)


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.has_method(&"take_damage"):
		_detonate()


func _on_area_entered(area: Area2D) -> void:
	var enemy := _resolve_enemy(area)
	if enemy != null:
		_detonate()


func _detonate() -> void:
	if _triggered:
		return
	_triggered = true

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
			SignalBus.damage_dealt.emit(final_damage, &"mine", enemy_type, was_crit)

			var dn := DamageNumberPool.create()
			var color := Color.YELLOW
			if was_crit:
				color = Color(0.9, 0.15, 0.05)
			var text := str(final_damage) + ("!" if was_crit else "")
			dn.play(text, color, enemy.global_position + Vector2(0, -16))

	var effect := EXPLOSION_EFFECT.instantiate()
	effect.global_position = global_position
	get_parent().add_child(effect)

	_active_mines.erase(self)
	queue_free()


func _resolve_enemy(area: Area2D) -> BaseEnemy:
	if area is BaseEnemy:
		return area
	var parent := area.get_parent()
	if parent is BaseEnemy:
		return parent
	return null
