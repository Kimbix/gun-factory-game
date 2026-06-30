class_name OutputPortBehavior
extends ComponentBehavior

## Output ports don't actively consume items; the Gun pulls items out of output ports.

func consume_phase(_comp: Component, _grid: Grid) -> void:
	pass


func push_phase(_comp: Component, _grid: Grid, _moved: Dictionary) -> bool:
	# An item sitting on the output port blocks further arrivals until the Gun drains it.
	return false


func emit_phase(_comp: Component, _grid: Grid) -> void:
	pass