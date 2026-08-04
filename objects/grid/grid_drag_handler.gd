class_name GridDragHandler
extends RefCounted
## Tracks a click-hold mouse drag over grid cells.
##
## Emits `entered` when a drag starts (on the press cell) and every time the
## drag crosses a new cell, so callers can act once per cell without repeated
## logic for press/release/cell-tracking state.

signal entered(cell: Vector2i)

var is_dragging := false
var last_cell := Vector2i(-1, -1)


func start(cell: Vector2i) -> void:
	if is_dragging:
		return
	is_dragging = true
	last_cell = cell
	entered.emit(cell)


func update(cell: Vector2i) -> void:
	if not is_dragging or cell == last_cell:
		return
	last_cell = cell
	entered.emit(cell)


func stop() -> void:
	is_dragging = false
