class_name Grid
extends RefCounted
## Pure simulation state for a gun's factory grid. No rendering.
## Single source of truth: every cell is either empty (null) or holds a Component.

const CELL_SIZE := 8

## Every cell in the chassis -> the Component placed there, or null if empty.
## Missing key means outside the chassis.
var contents: Dictionary[Vector2i, Component] = {}

## Emit quota: how many new items input ports may inject this tick. Set by the Gun
## before calling tick() to enforce the max-alive-items limit. InputPortBehavior
## decrements this each time it emits.
var emit_quota: int = 0


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


## Advances the simulation by one discrete tick. Three phases dispatched per
## component via its ComponentType.behavior:
##   A. consume_phase — drain finished items (output ports, etc.).
##   B. push_phase    — conveyors (and similar) push items out. Repeated passes
##                      until no behavior moves anything (train-shift semantics).
##   C. emit_phase    — input ports (and similar) inject new items.
func tick() -> void:
	var comps: Array[Component] = all_components()

	for comp in comps:
		if comp.type != null and comp.type.behavior != null:
			comp.type.behavior.consume_phase(comp, self)

	for comp in comps:
		if comp.item != null:
			comp.item.from_cell = comp.origin

	var moved: Dictionary[Item, bool] = {}
	for _pass in range(comps.size()):
		var any_moved := false
		for comp in comps:
			if comp.type == null or comp.type.behavior == null:
				continue
			if comp.type.behavior.push_phase(comp, self, moved):
				any_moved = true
		if not any_moved:
			break

	for comp in comps:
		if comp.type != null and comp.type.behavior != null:
			comp.type.behavior.emit_phase(comp, self)
