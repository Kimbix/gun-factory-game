class_name BuildingUI
extends BaseInterface


func open_factory_interface(grid: PlayerGrid) -> void:
	%PlayerGridViewer.grid = grid
	%PlayerGridViewer.queue_redraw()
	var view := get_viewport().get_visible_rect().size
	var new_size := Vector2(min(view.x, view.y), min(view.x, view.y))
	var new_pos := (get_viewport().get_visible_rect().size / 2.0)
	var center_offset := new_size / 2.0
	%PlayerGridViewer.set_final_size(new_size)
	%PlayerGridViewer.position = new_pos - center_offset


func close_factory_interface() -> void:
	%PlayerGridViewer.grid = null
	%PlayerGridViewer.queue_redraw()
