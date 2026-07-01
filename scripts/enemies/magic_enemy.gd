class_name MagicEnemy
extends BaseEnemy

@export var speed: float = 40.0
@export var slow_radius: float = 250.0

var _gun: Node2D
var _contact_timer: float = 0.0
var _debuff_applied: bool = false

const CONTACT_COOLDOWN := 0.5


func _ready() -> void:
	super()
	if player != null:
		_gun = player.get_node_or_null("Gun")


func _physics_process(delta: float) -> void:
	_update_hit_flash(delta)

	_contact_timer = maxf(_contact_timer - delta, 0.0)

	if player == null:
		return

	var dir := (player.global_position - global_position)
	var dist := dir.length()

	if dist > slow_radius * 0.7:
		velocity = dir.normalized() * speed
	else:
		var strafe := Vector2(dir.y, -dir.x).normalized()
		var side := 1 if int(floori(dist * 0.1)) % 2 == 0 else -1
		velocity = strafe * speed * side + dir.normalized() * speed * 0.3

	move_and_slide()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is Player and _contact_timer <= 0.0:
			_contact_timer = CONTACT_COOLDOWN
			col.get_collider().take_damage(1.0)

	if not _debuff_applied and dist <= slow_radius and _gun != null and _gun.has_method(&"apply_slow"):
		_gun.apply_slow()
		_debuff_applied = true
	elif _debuff_applied and dist > slow_radius and _gun != null and _gun.has_method(&"remove_slow"):
		_gun.remove_slow()
		_debuff_applied = false


func _exit_tree() -> void:
	if _debuff_applied and _gun != null and _gun.has_method(&"remove_slow"):
		_gun.remove_slow()


func _die() -> void:
	if _debuff_applied and _gun != null and _gun.has_method(&"remove_slow"):
		_gun.remove_slow()
		_debuff_applied = false
	super()
