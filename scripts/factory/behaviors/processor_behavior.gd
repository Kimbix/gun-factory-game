class_name ProcessorBehavior
extends ComponentBehavior

@export var processing_ticks: int = 3

func apply(_item: Item) -> void:
	pass

func consume_phase(comp: Component, _grid: Grid) -> void:
	if comp.item == null:
		return
	var ticks = comp.item.stats.get("_process_ticks")
	if ticks == null:
		comp.item.stats["_process_ticks"] = processing_ticks
		apply(comp.item)
	elif ticks > 0:
		comp.item.stats["_process_ticks"] = ticks - 1

func push_phase(comp: Component, grid: Grid, moved: Dictionary) -> bool:
	if comp.item == null or moved.has(comp.item):
		return false
	var ticks = comp.item.stats.get("_process_ticks")
	if ticks == null or ticks > 0:
		return false
	for port in comp.rotated_ports():
		if port.role != &"out":
			continue
		var next_cell: Vector2i = comp.origin + port.face
		var next_comp: Component = grid.component_at(next_cell)
		if next_comp == null or next_comp.item != null:
			continue
		var item := comp.item
		item.stats.erase("_process_ticks")
		next_comp.item = item
		comp.item = null
		moved[item] = true
		return true
	return false
