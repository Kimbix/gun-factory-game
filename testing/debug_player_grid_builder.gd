class_name DebugPlayerGridBuilder
extends Control

const GHOST_MODULATE := Color(1, 1, 1, 0.4)

@export_category("Functionality")
@export var viewer: PlayerGridViewer
@export var building_catalogue: BuildingCatalogue

var hovered_cell: Vector2i:
	get():
		var screen_mouse := viewer.get_global_mouse_position()
		var canvas_mouse := get_canvas_transform().affine_inverse() * screen_mouse
		var local_mouse := viewer.to_local(canvas_mouse)
		return Vector2i(local_mouse / PlayerGrid.GRID_TEXTURE_SIZE)
var pending_rotation: int = FactoryBuilding.Rotation.NORMAL
var _selected_building_index: int = 0
var _last_hovered: Vector2i = Vector2i(-1, -1)

@onready var grid := $BuildingsList


func _ready() -> void:
	_initialize_catalogue_viewer()


func _process(_delta: float) -> void:
	var h := hovered_cell
	if h != _last_hovered:
		_last_hovered = h
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return

	match event.button_index:
		MOUSE_BUTTON_RIGHT:
			viewer.grid.destroy_building(hovered_cell)
			viewer.queue_redraw()
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			var dir := 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1
			pending_rotation = (pending_rotation + dir + 4) % 4
			queue_redraw()
		MOUSE_BUTTON_LEFT:
			var component_info := building_catalogue.buildings[_selected_building_index]
			if component_info == null or viewer == null or viewer.grid == null:
				return
			viewer.grid.place_building(component_info, hovered_cell, pending_rotation)
			viewer.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.is_pressed():
		return
	if viewer == null or viewer.grid == null:
		return
	if not viewer.grid.has_building(hovered_cell):
		return

	match event.keycode:
		KEY_R:
			viewer.grid.rotate_building(hovered_cell, not Input.is_key_pressed(KEY_SHIFT))
			viewer.queue_redraw()


func _draw() -> void:
	if viewer == null or viewer.grid == null:
		return
	var to_draw := building_catalogue.get_texture(_selected_building_index)
	if to_draw == null:
		return

	var cell_origin := Vector2(hovered_cell) * PlayerGrid.GRID_TEXTURE_SIZE
	var cell_canvas := viewer.to_global(cell_origin)
	var cell_screen := get_canvas_transform() * cell_canvas
	var local_pos := cell_screen - global_position
	var viewer_sf := viewer.get_global_transform().get_scale()
	var ghost_center := to_draw.get_size() / 2.0
	var cell_center := local_pos + ghost_center * viewer_sf
	var radians := 0.0
	match pending_rotation % 4:
		FactoryBuilding.Rotation.CLOCKWISE:
			radians = PI / 2.0
		FactoryBuilding.Rotation.COUNTERCLOCKWISE:
			radians = -PI / 2.0
		FactoryBuilding.Rotation.FLIPPED:
			radians = PI

	draw_set_transform(cell_center, radians, viewer_sf)
	draw_texture(to_draw, -ghost_center, GHOST_MODULATE)


func _initialize_catalogue_viewer() -> void:
	for b_id: int in range(building_catalogue.buildings.size()):
		var building := building_catalogue.buildings[b_id]
		var text := TextureButton.new()
		text.texture_normal = building.texture
		text.custom_minimum_size = Vector2.ONE * 64
		text.button_down.connect(
			func() -> void:
				_selected_building_index = b_id
				queue_redraw()
		)
		grid.add_child(text)
