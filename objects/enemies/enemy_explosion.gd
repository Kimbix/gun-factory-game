class_name EnemyExplosion
extends BaseEnemy

## Distance to the player that triggers the fuse sequence.
@export var proximity_range := 20.0
## How many times the enemy flashes red before exploding.
@export var flash_count := 3
## How long each red flash stays visible, in seconds.
@export var flash_duration := 0.2
## Radius around the enemy that takes damage on explosion.
@export var explosion_radius := 20.0
## Base damage dealt by the explosion, scaled by [member BaseEnemy.damage_multiplier].
@export var explosion_damage := 30.0

var _sprite: Sprite2D
var _fusing := false
var _flash_timer := 0.0
var _flash_on := false
var _flashes_done := 0


func _ready() -> void:
	super()
	_sprite = $Sprite2D


func _physics_process(delta: float) -> void:
	super(delta)
	if _fusing:
		_process_fuse(delta)
		return
	if player != null and is_instance_valid(player):
		if global_position.distance_to(player.global_position) <= proximity_range:
			_start_fuse()


func _start_fuse() -> void:
	_fusing = true
	_flash_timer = 0.0
	_flash_on = false
	_flashes_done = 0
	_set_flash(false)


func _process_fuse(delta: float) -> void:
	_flash_timer += delta
	if _flash_timer < flash_duration:
		return
	_flash_timer = 0.0
	if _flash_on:
		_flash_on = false
		_set_flash(false)
		_flashes_done += 1
		if _flashes_done >= flash_count:
			_explode()
	else:
		_flash_on = true
		_set_flash(true)


func _set_flash(on: bool) -> void:
	if _sprite == null or not is_instance_valid(_sprite):
		return
	_sprite.modulate = Color.RED if on else Color.WHITE


func _explode() -> void:
	_set_flash(false)
	if is_instance_valid(player):
		var dist := global_position.distance_to(player.global_position)
		if dist <= explosion_radius:
			var read_enemy_type := StringName(BaseEnemy.EnemyType.keys()[enemy_type])
			player.take_damage(explosion_damage * damage_multiplier, read_enemy_type)
	_dead = true
	var enemy_type_name := StringName(BaseEnemy.EnemyType.keys()[enemy_type])
	SignalBus.enemy_killed.emit(enemy_type_name)
	queue_free()
