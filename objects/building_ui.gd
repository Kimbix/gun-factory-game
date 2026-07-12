class_name BuildingUI
extends BaseInterface

const PLAYER_GRID_VIEWER := preload("uid://dq2aqdo8qs8ft")

var _building := false

@onready var player_grid_viewer := $PlayerGridViewer


func toggle_building_interface() -> void:
	if _building:
		close_factory_interface()
		GameSupervisor.instance.unpause_gameplay()
	else:
		open_factory_interface()
		GameSupervisor.instance.pause_gameplay()
	_building = not _building


func open_factory_interface() -> void:
	var grid := GameSupervisor.instance.get_player().player_grid
	player_grid_viewer.grid = grid
	player_grid_viewer.queue_redraw()
	var view := get_viewport().get_visible_rect().size
	var new_size := Vector2(min(view.x, view.y), min(view.x, view.y))
	var new_pos := (get_viewport().get_visible_rect().size / 2.0)
	var center_offset := new_size / 2.0
	player_grid_viewer.set_final_size(new_size)
	player_grid_viewer.position = new_pos - center_offset


func close_factory_interface() -> void:
	player_grid_viewer.grid = null
	player_grid_viewer.queue_redraw()
