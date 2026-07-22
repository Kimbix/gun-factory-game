class_name GridInteractor
extends Node2D
## This class handles the creation of interfaces to interact with the factory items

enum InteractorState {
	ACTIVE,
	INACTIVE,
}

@export var state: InteractorState
@export var builder: GridBuilder
@export var building_ui: BuildingUI
@export var interface_supervisor: InterfaceSupervisor

var building_inventory: PlayerBuildingInventory
var hovered_cell: Vector2i:
	get():
		return viewer.get_hovered_cell()

@onready var viewer: PlayerGridViewer = get_parent()


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
			b.behaviour.open_interface(interface_supervisor)
			viewer.queue_redraw()
		MOUSE_BUTTON_RIGHT:
			if builder != null and builder.selected_info != null:
				return
			if not viewer.grid.has_building(hovered_cell):
				return
			var info := viewer.grid.get_building(hovered_cell).get_info()
			viewer.grid.destroy_building(hovered_cell)
			building_inventory.add(info)
			if building_ui != null:
				building_ui.refresh_building_list()
			viewer.queue_redraw()
