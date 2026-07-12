class_name GridInteractor
extends Node2D
## This class handles the creation of interfaces to interact with the factory items

enum InteractorState {
	ACTIVE,
	INACTIVE,
}

@export var state: InteractorState

var hovered_cell: Vector2i:
	get():
		var screen_mouse := viewer.get_global_mouse_position()
		var canvas_mouse := get_canvas_transform().affine_inverse() * screen_mouse
		var local_mouse := viewer.to_local(canvas_mouse)
		return Vector2i(local_mouse / PlayerGridViewer.GRID_TEXTURE_SIZE)

@onready var viewer: PlayerGridViewer = get_parent()
@onready var builder: GridBuilder = _find_builder()


func _unhandled_input(event: InputEvent) -> void:
	if viewer.grid == null:
		return
	if not (event is InputEventMouseButton and event.pressed):
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if builder != null and builder.selected_info != null:
				return
			var b := viewer.grid.get_building(hovered_cell)
			if b == null or b.behaviour == null:
				return
			b.behaviour.open_interface()
			viewer.queue_redraw()
		MOUSE_BUTTON_RIGHT:
			if builder != null and builder.selected_info != null:
				return
			if not viewer.grid.has_building(hovered_cell):
				return
			var info := viewer.grid.get_building(hovered_cell).get_info()
			viewer.grid.destroy_building(hovered_cell)
			GameSupervisor.instance.get_player().building_inventory.add(info)
			var ui := viewer.get_parent() as BuildingUI
			if ui != null:
				ui.refresh_building_list()
			viewer.queue_redraw()


func _find_builder() -> GridBuilder:
	for child in get_parent().get_children():
		if child is GridBuilder:
			return child
	return null
