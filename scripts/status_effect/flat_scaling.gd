class_name FlatScaling
extends ScalingStrategy

var value: float


func _init(p_value: float = 0.0) -> void:
	value = p_value


func evaluate(_stacks: int) -> float:
	return value
