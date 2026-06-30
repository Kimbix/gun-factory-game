class_name ExpressConveyorBehavior
extends ComponentBehavior

## Multiplier for the item's visual interpolation speed (1.0 = normal).
@export var interp_speed: float = 2.0


func push_phase(comp: Component, grid: Grid, moved: Dictionary) -> bool:
	if comp.item == null:
		return false
	comp.item.stats["interp_speed"] = interp_speed
	for port in comp.rotated_ports():
		if port.role != &"out":
			continue
		var next_cell: Vector2i = comp.origin + port.face
		if not grid.has_cell(next_cell):
			continue
		var next_comp: Component = grid.component_at(next_cell)
		if next_comp == null or next_comp.item != null:
			continue
		if not next_comp.can_receive_from(comp.origin):
			continue
		if moved.has(comp.item):
			moved.erase(comp.item)
		next_comp.item = comp.item
		comp.item = null
		moved[next_comp.item] = true
		return true
	return false
