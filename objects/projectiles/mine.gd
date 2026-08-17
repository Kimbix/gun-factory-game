class_name Mine
extends Node2D

signal flashing_ended

const FLASH_COUNT := 3
const FLASH_DURATION := .25
const MAX_MINES := 256
const EXPLOSION_EFFECT := preload("uid://ltos725goucd")

static var _active_mines: Array[Mine] = []

@export var _sprite: Sprite2D
@export var detection_area: Area2D
@export var damage_area: Area2D

var damage := 20
var shooter: Node2D
var player_stats: PlayerStats
var _triggered := false


func _ready() -> void:
	_active_mines.append(self)
	if _active_mines.size() > MAX_MINES:
		_active_mines[0].die_silently()
		_active_mines.remove_at(0)

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.area_entered.connect(_on_area_entered)


func _exit_tree() -> void:
	_active_mines.erase(self)


func die_silently() -> void:
	_active_mines.erase(self)
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.has_method(&"take_damage"):
		_detonate()


func _on_area_entered(area: Area2D) -> void:
	var enemy := _resolve_enemy(area)
	if enemy != null:
		_detonate()


## TODO: Extract this big ass damage function to something simpler
func _damage_enemy(enemy: BaseEnemy) -> void:
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


func _set_flash(on: bool) -> void:
	if _sprite == null or not is_instance_valid(_sprite):
		return
	_sprite.modulate = Color.RED if on else Color.WHITE


func _detonate_flash() -> void:
	for i: int in FLASH_COUNT:
		_set_flash(true)
		await get_tree().create_timer(FLASH_DURATION * .5).timeout
		_set_flash(false)
		await get_tree().create_timer(FLASH_DURATION * .5).timeout
	flashing_ended.emit()


func _detonate() -> void:
	if _triggered:
		return
	_triggered = true

	_detonate_flash()
	await flashing_ended

	for n: Node in damage_area.get_overlapping_areas():
		if n is not BaseEnemy:
			continue
		_damage_enemy(n)

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
