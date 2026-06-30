class_name Grid
extends RefCounted
## Pure simulation state for a gun's factory grid. No rendering.
## Single source of truth: every cell is either empty (null) or holds a Component.

const CELL_SIZE := 8

## Every cell in the chassis -> the Component placed there, or null if empty.
## Missing key means outside the chassis.
var contents: Dictionary[Vector2i, Component] = { }


func _to_string() -> String:
	var n := 0
	for c in contents.values():
		if c != null:
			n += 1
	return "Grid(cells=%d, occupied=%d)" % [contents.size(), n]

# --- Construction -----------------------------------------------------------


## Builds a rectangular walkable grid of size `w` x `h`. All cells start empty.
func build_rect(w: int, h: int) -> void:
	contents.clear()
	for y in range(h):
		for x in range(w):
			contents[Vector2i(x, y)] = null


func has_cell(cell: Vector2i) -> bool:
	return contents.has(cell)


func component_at(cell: Vector2i) -> Component:
	return contents.get(cell)


func is_empty(cell: Vector2i) -> bool:
	return contents.get(cell) == null

# --- Placement --------------------------------------------------------------


func can_place(component: Component, origin: Vector2i, rotation: int) -> bool:
	for c in component.footprint_cells(origin, rotation):
		if not has_cell(c):
			return false
		if not is_empty(c):
			return false
	return true


func place(component: Component, origin: Vector2i, rotation: int) -> bool:
	if not can_place(component, origin, rotation):
		return false
	component.origin = origin
	component.rotation = rotation
	for c in component.footprint_cells(origin, rotation):
		contents[c] = component
	return true


func remove(component: Component) -> void:
	for c in component.footprint_cells(component.origin, component.rotation):
		if contents.get(c) == component:
			contents[c] = null


func remove_at(cell: Vector2i) -> Component:
	var comp: Component = contents.get(cell)
	if comp == null:
		return null
	remove(comp)
	return comp


func all_components() -> Array[Component]:
	var seen: Dictionary = { }
	var out: Array[Component] = []
	for c in contents.values():
		if c != null and not seen.has(c):
			seen[c] = true
			out.append(c)
	return out


## Advances the simulation by one discrete tick. Three phases:
##   A. Output ports consume any item sitting on them.
##   B. Conveyors push their item to the next cell (snapshot-based so each item moves at
##      most one cell per tick).
##   C. Input ports emit a new item onto their facing neighbor if there is space.
func tick() -> void:
	var comps: Array[Component] = all_components()

	# Phase A: output ports consume.
	for comp in comps:
		if comp.type != null and comp.type.kind == &"output_port" and comp.item != null:
			comp.item = null

	# Snapshot: every surviving item records where it starts this tick (its owning
	# component's origin). Used by the viewer to interpolate movement.
	for comp in comps:
		if comp.item != null:
			comp.item.from_cell = comp.origin

	# Phase B: conveyor push, train-shift semantics.
	# Each item may move at most one cell per tick (tracked by `moved`). Within a tick we
	# do passes until no further move is possible, so downstream moves free up cells for
	# upstream conveyors in the same tick. This makes a packed belt shift one full step
	# per tick instead of "bubbling" at half speed.
	var conveyors: Array[Component] = []
	for comp in comps:
		if comp.type != null and comp.type.kind == &"conveyor":
			conveyors.append(comp)
	var moved: Dictionary[Item, bool] = { }
	for _pass in range(conveyors.size()):
		var any_moved := false
		for conv in conveyors:
			if conv.item == null or moved.has(conv.item):
				continue
			var next_comp: Component = component_at(conv.origin + conv.facing_vector())
			if next_comp == null or next_comp.item != null:
				continue
			next_comp.item = conv.item
			conv.item = null
			moved[next_comp.item] = true
			any_moved = true
		if not any_moved:
			break

	# Phase C: input ports emit. New item's from_cell is itself (no slide-in yet).
	for comp in comps:
		if comp.type == null or comp.type.kind != &"input_port":
			continue
		var next_cell: Vector2i = comp.origin + comp.facing_vector()
		var next_comp: Component = component_at(next_cell)
		if next_comp != null and next_comp.item == null:
			var new_item := Item.new(comp.type.material, { })
			new_item.from_cell = comp.origin # slide from input port into the conveyor
			next_comp.item = new_item
