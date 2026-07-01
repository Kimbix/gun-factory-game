class_name RoomActivator
extends Area2D

@export var barrier_group: String = "barrier"
@export var clear_delay: float = 1.5

signal room_cleared

var _current_wave: int = -1
var _active_enemies: int = 0
var _is_active: bool = false
var _spawn_points: Array[Node2D] = []
var _barriers: Array[Node2D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 1
	call_deferred(&"_setup")


func _setup() -> void:
	var parent := get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child.is_in_group("spawn_point"):
			_spawn_points.append(child)
		if child.is_in_group("barrier"):
			_barriers.append(child)


func _on_body_entered(body: Node) -> void:
	if _is_active:
		return
	if not body is Player:
		return
	_is_active = true
	_lock_room()
	_start_next_wave()


func _lock_room() -> void:
	for b in _barriers:
		b.visible = true
		var sb := b as StaticBody2D
		if sb != null:
			sb.collision_layer = 1
		for child in b.get_children():
			if child is Sprite2D:
				child.visible = true
			if child is CollisionShape2D:
				child.disabled = false


func _unlock_room() -> void:
	for b in _barriers:
		b.visible = false
		var sb := b as StaticBody2D
		if sb != null:
			sb.collision_layer = 0
		for child in b.get_children():
			if child is Sprite2D:
				child.visible = false
			if child is CollisionShape2D:
				child.disabled = true


func _start_next_wave() -> void:
	_current_wave += 1
	var spawned := false
	for sp in _spawn_points:
		if not sp.has_method("get_spawns_for_wave"):
			continue
		var scenes: Array = sp.call("get_spawns_for_wave", _current_wave)
		for s in scenes:
			_spawn_enemy(s, sp)
			_active_enemies += 1
			spawned = true
	if not spawned:
		await get_tree().create_timer(clear_delay).timeout
		_unlock_room()
		room_cleared.emit()


func _spawn_enemy(scene: PackedScene, at: Node2D) -> void:
	if scene == null:
		return
	var enemy := scene.instantiate()
	enemy.position = at.global_position
	var parent := get_parent()
	if parent != null:
		parent.add_child(enemy)
	else:
		get_tree().current_scene.add_child(enemy)
	var be := enemy as BaseEnemy
	if be != null and not be.died.is_connected(_on_enemy_died):
		be.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0:
		_start_next_wave()
