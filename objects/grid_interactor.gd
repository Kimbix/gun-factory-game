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
		return Vector2i(local_mouse / PlayerGrid.GRID_TEXTURE_SIZE)

@onready var viewer: PlayerGridViewer = get_parent()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			var b := viewer.grid.get_building(hovered_cell)
			if b == null:
				return
			b.behaviour.open_interface()
			viewer.queue_redraw()
