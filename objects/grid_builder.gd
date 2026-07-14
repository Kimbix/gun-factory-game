class_name GridBuilder
extends Node2D
## Handles placement of new buildings on the grid with a ghost preview,
## rotation via mouse wheel, and inventory validation.

const GHOST_MODULATE := Color(1, 1, 1, 0.4)

var building_inventory: PlayerBuildingInventory
@export var building_ui: BuildingUI

var selected_info: GridComponentInfo:
	set(v):
		selected_info = v
		pending_rotation = FactoryBuilding.Rotation.NORMAL
		queue_redraw()
var pending_rotation: int = FactoryBuilding.Rotation.NORMAL
var hovered_cell: Vector2i:
	get():
		return viewer.get_hovered_cell()
var _last_hovered: Vector2i = Vector2i(-1, -1)

@onready var viewer: PlayerGridViewer = get_parent()


func _process(_delta: float) -> void:
	if selected_info == null:
		return
	var h := hovered_cell
	if h != _last_hovered:
		_last_hovered = h
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if viewer == null or viewer.grid == null:
		return
	if not (event is InputEventMouseButton and event.pressed):
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if selected_info == null:
				return
			_try_place()
			get_viewport().set_input_as_handled()
		MOUSE_BUTTON_RIGHT:
			if selected_info == null:
				return
			deselect()
			get_viewport().set_input_as_handled()
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			if selected_info == null:
				return
			var dir := 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
			pending_rotation = (pending_rotation + dir + 4) % 4
			queue_redraw()
			get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.is_pressed():
		return
	if viewer == null or viewer.grid == null:
		return

	match event.keycode:
		KEY_R:
			if selected_info != null:
				pending_rotation = (pending_rotation + 1) % 4
				queue_redraw()
			elif viewer.grid.has_building(hovered_cell):
				viewer.grid.rotate_building(hovered_cell, not Input.is_key_pressed(KEY_SHIFT))
				viewer.queue_redraw()
		KEY_ESCAPE:
			if selected_info == null:
				return
			deselect()
			get_viewport().set_input_as_handled()


func _draw() -> void:
	if selected_info == null or viewer == null or viewer.grid == null:
		return

	var to_draw := selected_info.texture
	if to_draw == null:
		return

	var cell := hovered_cell
	if viewer.grid.dimensions.x <= cell.x or viewer.grid.dimensions.y <= cell.y \
			or cell.x < 0 or cell.y < 0:
		return

	var cell_origin := Vector2(cell) * PlayerGridViewer.GRID_TEXTURE_SIZE
	var ghost_center := to_draw.get_size() / 2.0

	var radians := FactoryBuilding.rotation_to_radians(pending_rotation)

	draw_set_transform(cell_origin + ghost_center, radians, Vector2.ONE)
	draw_texture(to_draw, -ghost_center, GHOST_MODULATE)


func select(info: GridComponentInfo) -> void:
	selected_info = info


func deselect() -> void:
	selected_info = null
	queue_redraw()


func _try_place() -> void:
	var cell := hovered_cell
	if viewer.grid.dimensions.x <= cell.x or viewer.grid.dimensions.y <= cell.y \
			or cell.x < 0 or cell.y < 0:
		return
	if viewer.grid.has_building(cell):
		return

	if not building_inventory.has(selected_info):
		return
	if not building_inventory.remove(selected_info):
		return

	viewer.grid.place_building(selected_info, cell, pending_rotation)
	viewer.queue_redraw()

	if not building_inventory.has(selected_info):
		deselect()

	if building_ui != null:
		building_ui.refresh_building_list()
