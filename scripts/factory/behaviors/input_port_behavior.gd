class_name InputPortBehavior
extends ComponentBehavior

## Emits a fresh item from each OUTPUT face of the input port. One item per face
## per tick, only if the destination cell is empty.


func emit_phase(comp: Component, grid: Grid) -> void:
	if grid.emit_quota <= 0:
		return
	for port in comp.rotated_ports():
		if port.role != &"out":
			continue
		if grid.emit_quota <= 0:
			break
		var next_cell: Vector2i = comp.origin + port.face
		var next_comp: Component = grid.component_at(next_cell)
		if next_comp != null and next_comp.item == null:
			var item := Item.new(comp.type.material, {})
			item.from_cell = comp.origin
			next_comp.item = item
			grid.emit_quota -= 1