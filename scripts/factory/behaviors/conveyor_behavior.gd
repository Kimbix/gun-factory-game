class_name ConveyorBehavior
extends ComponentBehavior

## Pushes the component's item out of every OUTPUT face. Returns true if any item
## moved. Grid repeats passes until stable (train-shift semantics).
## `moved` deduplicates so one item moves at most one cell per tick.


func push_phase(comp: Component, grid: Grid, moved: Dictionary) -> bool:
	if comp.item == null or moved.has(comp.item):
		return false
	for port in comp.rotated_ports():
		if port.role != &"out":
			continue
		var next_cell: Vector2i = comp.origin + port.face
		var next_comp: Component = grid.component_at(next_cell)
		if next_comp == null or next_comp.item != null:
			continue
		next_comp.item = comp.item
		comp.item = null
		moved[next_comp.item] = true
		return true
	return false