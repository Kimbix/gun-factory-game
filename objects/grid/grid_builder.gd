class_name GridBuilder
extends Node2D
## Handles placement of new buildings on the grid with a ghost preview,
## rotation via mouse wheel, and inventory validation.

signal selection_changed(info: GridComponentInfo)

enum Mode {
	SINGLE,
	SELECTION,
}

const GHOST_MODULATE := Color(1, 1, 1, 0.4)

@export var building_ui: BuildingUI

var building_inventory: PlayerBuildingInventory
var selected_info: GridComponentInfo:
	set(v):
		selected_info = v
		pending_rotation = FactoryBuilding.Rotation.NORMAL
		selection_changed.emit(v)
		queue_redraw()
var pending_rotation: int = FactoryBuilding.Rotation.NORMAL
var hovered_cell: Vector2i:
	get():
		return viewer.get_hovered_cell()
var _current_mode: Mode = Mode.SINGLE
var _last_hovered: Vector2i = Vector2i(-1, -1)
var _drag_place := GridDragHandler.new()
var _drag_delete := GridDragHandler.new()
var _active_selection: GridSelection

@onready var viewer: PlayerGridViewer = get_parent()


func _ready() -> void:
	_drag_place.entered.connect(_on_place_drag_entered)
	_drag_delete.entered.connect(_on_delete_drag_entered)


func _process(_delta: float) -> void:
	if is_instance_valid(_active_selection) and _active_selection.selecting:
		_active_selection.corner_two = hovered_cell

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_drag_place.stop()
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_drag_delete.stop()
	if is_instance_valid(_active_selection) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_active_selection.drag_handler.stop()

	if selected_info == null:
		_drag_place.stop()
	var h := hovered_cell
	if h != _last_hovered:
		_last_hovered = h
		queue_redraw()
	_drag_place.update(h)
	_drag_delete.update(h)
	if is_instance_valid(_active_selection) and not _active_selection.selecting:
		_active_selection.drag_handler.update(h)


func _unhandled_input(event: InputEvent) -> void:
	if viewer == null or viewer.grid == null:
		return

	if event is InputEventKey:
		_handle_keyboard_press(event)

	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)


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
			if selected_info == null and _active_selection == null:
				return
			if selected_info != null:
				deselect()
			_clear_selection()
			_current_mode = Mode.SINGLE
			get_viewport().set_input_as_handled()


func _draw() -> void:
	if selected_info == null or viewer == null or viewer.grid == null:
		return

	var to_draw := selected_info.texture
	if to_draw == null:
		return

	var cell := hovered_cell
	if (viewer.grid.dimensions.x <= cell.x
			or viewer.grid.dimensions.y <= cell.y
			or cell.x < 0 or cell.y < 0):
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


func is_in_selection_mode() -> bool:
	return _current_mode == Mode.SELECTION


func _clear_selection() -> void:
	if _active_selection != null:
		_active_selection.rect.queue_free()
		_active_selection = null


func _create_selection(cell: Vector2i) -> void:
	_active_selection = GridSelection.new(cell, viewer.grid)
	_active_selection.moved.connect(viewer.queue_redraw)
	_active_selection.overridden.connect(_on_building_overridden)
	self.add_child(_active_selection.rect)


func _handle_keyboard_press(event: InputEventKey) -> void:
	if event.keycode == KEY_SHIFT:
		if _drag_place.is_dragging or _drag_delete.is_dragging:
			return
		if event.is_pressed():
			_current_mode = Mode.SELECTION
		elif _active_selection == null:
			_current_mode = Mode.SINGLE


func _handle_mouse_button_input(event: InputEventMouseButton) -> void:
	if _current_mode == Mode.SELECTION and _active_selection != null:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_key_pressed(KEY_SHIFT):
				_clear_selection()
				_create_selection(hovered_cell)
			else:
				_active_selection.selecting = false
				_active_selection.drag_handler.start(hovered_cell)
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			_clear_selection()
			_current_mode = Mode.SINGLE
		elif event.is_released():
			_active_selection.selecting = false
			_active_selection.drag_handler.stop()
		return

	if _current_mode == Mode.SELECTION and _active_selection == null:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			_create_selection(hovered_cell)
		return

	if event.is_released():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_drag_place.stop()
			MOUSE_BUTTON_RIGHT:
				_drag_delete.stop()
		return

	if event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_handle_mouse_button_left()
			MOUSE_BUTTON_RIGHT:
				_handle_mouse_button_right()
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				_handle_mouse_wheel(event.button_index)


func _handle_mouse_button_left() -> void:
	if selected_info == null:
		return
	_drag_place.start(hovered_cell)


func _handle_mouse_button_right() -> void:
	if selected_info != null:
		deselect()
	else:
		_drag_delete.start(hovered_cell)


func _handle_mouse_wheel(button_index: MouseButton) -> void:
	if selected_info == null:
		return
	var dir := 1 if button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
	pending_rotation = (pending_rotation + dir + 4) % 4
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


func _on_place_drag_entered(_cell: Vector2i) -> void:
	_try_place()


func _on_delete_drag_entered(_cell: Vector2i) -> void:
	_try_delete()


func _on_building_overridden(info: GridComponentInfo) -> void:
	building_inventory.add(info)
	if building_ui != null:
		building_ui.refresh_building_list()


func _try_delete() -> void:
	var cell := hovered_cell
	if viewer.grid.dimensions.x <= cell.x or viewer.grid.dimensions.y <= cell.y \
			or cell.x < 0 or cell.y < 0:
		return
	if not viewer.grid.has_building(cell):
		return
	var info := viewer.grid.get_building(cell).get_info()
	viewer.grid.destroy_building(cell)
	building_inventory.add(info)
	if building_ui != null:
		building_ui.refresh_building_list()
	viewer.queue_redraw()


class GridSelection:
	signal moved
	signal overridden(info: GridComponentInfo)

	const SELECTION_RECTANGLE := preload("uid://sdop7ejadnma")

	var drag_handler: GridDragHandler
	var target_grid: PlayerGrid
	var selecting: bool
	var rect: NinePatchRect
	var corner_one: Vector2i:
		get():
			return corner_one
		set(v):
			corner_one = v
			fix_size_and_position()
	var corner_two: Vector2i:
		get():
			return corner_two
		set(v):
			corner_two = v
			fix_size_and_position()


	func fix_size_and_position() -> void:
		var corner_sum: Vector2 = corner_one + corner_two
		var corner_diff: Vector2 = abs(corner_one - corner_two)
		var to_scale := PlayerGridViewer.GRID_TEXTURE_SIZE
		rect.position = ((corner_sum - corner_diff) / 2.0) * to_scale
		rect.size = (corner_diff + Vector2.ONE) * to_scale


	func _on_dragged(cell: Vector2i) -> void:
		var delta := cell - drag_handler.last_cell
		if delta == Vector2i.ZERO:
			return

		var start_vector := Vector2i(mini(corner_one.x, corner_two.x), mini(corner_one.y, corner_two.y))
		var end_vector := Vector2i(maxi(corner_one.x, corner_two.x), maxi(corner_one.y, corner_two.y))

		var origins: Array[Vector2i] = []
		for x: int in range(start_vector.x, end_vector.x + 1):
			for y: int in range(start_vector.y, end_vector.y + 1):
				origins.append(Vector2i(x, y))

		for v: Vector2i in origins:
			if not target_grid.has_building(v):
				continue
			var to := target_grid.get_building(v).position + delta
			if to.x < 0 or to.y < 0 or to.x >= target_grid.dimensions.x or to.y >= target_grid.dimensions.y:
				return

		var overridden_infos: Array[GridComponentInfo] = target_grid.move_buildings(origins, delta)
		for info: GridComponentInfo in overridden_infos:
			overridden.emit(info)

		corner_one += delta
		corner_two += delta
		moved.emit()


	func _init(starting_cell: Vector2, grid: PlayerGrid) -> void:
		var instance := SELECTION_RECTANGLE.instantiate()
		rect = instance
		corner_one = starting_cell
		corner_two = starting_cell
		selecting = true
		target_grid = grid
		drag_handler = GridDragHandler.new()
		drag_handler.entered.connect(_on_dragged)
