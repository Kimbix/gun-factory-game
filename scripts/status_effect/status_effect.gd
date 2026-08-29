class_name StatusEffect
extends RefCounted

var effect_name: StringName = &""
var duration: float = 3.0
var refreshes_others: bool = false
var scaling: ScalingStrategy = null

var stack_count: int = 0
var remaining_time: float = 0.0
var tick_interval: float = 1.0
var _tick_timer: float = 0.0
var _particles: GPUParticles2D = null


func add_stack() -> void:
	stack_count += 1
	if stack_count == 1:
		remaining_time = duration
	elif refreshes_others:
		remaining_time = duration


func update(delta: float, enemy: BaseEnemy) -> void:
	remaining_time -= delta
	if remaining_time <= 0.0:
		return
	_tick_timer += delta
	if _tick_timer >= tick_interval:
		_tick_timer -= tick_interval
		var magnitude := get_magnitude()
		apply_effect(magnitude, tick_interval, enemy)


func get_magnitude() -> float:
	if scaling == null:
		return 0.0
	return scaling.evaluate(stack_count)


func is_expired() -> bool:
	return remaining_time <= 0.0


func apply_effect(_magnitude: float, _delta: float, _enemy: BaseEnemy) -> void:
	pass


func on_afflict(_enemy: BaseEnemy) -> void:
	pass


func on_remove(_enemy: BaseEnemy) -> void:
	pass
