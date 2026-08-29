class_name LinearScaling
extends ScalingStrategy

var a: float
var b: float


func _init(p_a: float = 0.0, p_b: float = 1.0) -> void:
	a = p_a
	b = p_b


func evaluate(stacks: int) -> float:
	return a + b * stacks
