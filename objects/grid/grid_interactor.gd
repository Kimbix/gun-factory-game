class_name GridInteractor
extends Node2D
## This class handles the creation of interfaces to interact with the factory items

enum InteractorState {
	ACTIVE,
	INACTIVE,
}

@export var state: InteractorState
@export var builder: GridBuilder
@export var interface_supervisor: InterfaceSupervisor

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
