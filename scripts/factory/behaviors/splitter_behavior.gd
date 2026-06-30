class_name SplitterBehavior
extends ComponentBehavior

var _next_output: Dictionary = {}


func push_phase(comp: Component, grid: Grid, moved: Dictionary) -> bool:
	if comp.item == null:
		return false
	var outputs = []
	for port in comp.rotated_ports():
		if port.role == &"out":
			outputs.append(port.face as Vector2i)
	if outputs.is_empty():
		return false
	var id = comp.get_instance_id()
	var start = _next_output.get(id, 0) as int
	for i in outputs.size():
		var dir_idx: int = (start + i) % outputs.size()
		var face: Vector2i = outputs[dir_idx]
		var next_cell: Vector2i = comp.origin + face
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
		_next_output[id] = (dir_idx + 1) % outputs.size()
		return true
	return false
