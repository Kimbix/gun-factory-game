class_name ComponentBehavior
extends Resource

## Strategy object. One instance per ComponentType, authored as .tres.
## Grid.tick() calls these in phase order on every component:
##   A. consume_phase — drain finished items (output ports).
##   B. push_phase    — move items along conveyors. Returns true if this component
##                      moved an item this call; Grid repeats passes until stable.
##   C. emit_phase    — inject new items into the grid (input ports).
## Default implementations are no-ops; subclasses override what they need.


func consume_phase(_comp: Component, _grid: Grid) -> void:
	pass


func push_phase(_comp: Component, _grid: Grid, _moved: Dictionary) -> bool:
	return false


func emit_phase(_comp: Component, _grid: Grid) -> void:
	pass