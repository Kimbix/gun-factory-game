class_name OutputPortBehavior
extends ComponentBehavior

## Consumes any item sitting on the output port's cell.


func consume_phase(comp: Component, _grid: Grid) -> void:
	if comp.item != null:
		comp.item = null