class_name SlimeEnemy
extends BaseEnemy

@export var speed: float = 50.0
@export var fire_interval: float = 1.5

var _contact_timer: float = 0.0
var _direction_timer: float = 0.0
var _fire_timer: float = 0.0
var _move_dir: Vector2

const CONTACT_COOLDOWN := 0.5
const DIRECTION_CHANGE := 2.0
const SLIME_FIRE := preload("res://slime_fire.tscn")


func _ready() -> void:
	super()
	_change_direction()


func _change_direction() -> void:
	var angle := randf_range(0.0, TAU)
	_move_dir = Vector2(cos(angle), sin(angle))


func _physics_process(delta: float) -> void:
	_update_hit_flash(delta)

	_contact_timer = maxf(_contact_timer - delta, 0.0)
	_fire_timer -= delta
	_direction_timer -= delta

	if _direction_timer <= 0.0:
		_direction_timer = DIRECTION_CHANGE + randf_range(-0.5, 0.5)
		_change_direction()

	velocity = _move_dir * speed
	move_and_slide()

	if _move_dir.length() > 0.0 and get_slide_collision_count() > 0:
		_move_dir = -_move_dir

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is Player and _contact_timer <= 0.0:
			_contact_timer = CONTACT_COOLDOWN
			col.get_collider().take_damage(1.0)

	if _fire_timer <= 0.0:
		_fire_timer = fire_interval + randf_range(-0.3, 0.3)
		_drop_fire()


func _drop_fire() -> void:
	var fire := SLIME_FIRE.instantiate()
	fire.position = position
	var parent := get_parent()
	if parent != null:
		parent.add_child(fire)
	else:
		get_tree().current_scene.add_child(fire)
