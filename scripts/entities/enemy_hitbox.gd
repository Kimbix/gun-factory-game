class_name EnemyHitbox
extends Area2D

@export var damage_per_tick: float = 1.0
@export var tick_interval_frames: int = 3

var _player: Node2D
var _frame_count: int


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_frame_count = tick_interval_frames


func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	_frame_count += 1
	if _frame_count >= tick_interval_frames:
		_frame_count = 0
		if is_instance_valid(_player) and _player.has_method(&"take_damage"):
			var mult := 1.0
			var enemy_type := &""
			var parent := get_parent() as BaseEnemy
			if parent != null:
				mult = parent.damage_multiplier
				enemy_type = StringName(BaseEnemy.EnemyType.keys()[parent.enemy_type])
			_player.take_damage(damage_per_tick * mult, enemy_type)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body
		_frame_count = tick_interval_frames


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_frame_count = 0
