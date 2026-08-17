class_name BuildingUI
extends BaseInterface

@export var player_grid: PlayerGrid
@export var grid_builder: GridBuilder

var building_inventory: PlayerBuildingInventory
var _building := false
var _selected_button: Button = null

@onready var player_grid_viewer := $PlayerGridViewer
@onready var building_panel := $BuildingInventoryPanel
@onready var building_list := %BuildingList
@onready var shop_panel := $ShopPanel


func open_building_interface() -> void:
	if _building:
		return
	process_mode = PROCESS_MODE_INHERIT
	open_factory_interface()
	shop_panel.building_inventory = building_inventory
	shop_panel.refresh()
	shop_panel.show()
	if not building_inventory.changed.is_connected(refresh_building_list):
		building_inventory.changed.connect(refresh_building_list)
	if not grid_builder.selection_changed.is_connected(_on_selection_changed):
		grid_builder.selection_changed.connect(_on_selection_changed)
	_populate_building_list()
	_building = true


func close_building_interface() -> void:
	if not _building:
		return
	if grid_builder != null:
		grid_builder.deselect()
	close_factory_interface()
	if building_inventory.changed.is_connected(refresh_building_list):
		building_inventory.changed.disconnect(refresh_building_list)
	if grid_builder != null and grid_builder.selection_changed.is_connected(_on_selection_changed):
		grid_builder.selection_changed.disconnect(_on_selection_changed)
	_clear_building_list()
	shop_panel.hide()
	_building = false
	process_mode = PROCESS_MODE_DISABLED


func is_building_interface_open() -> bool:
	return _building


func open_factory_interface() -> void:
	player_grid_viewer.grid = player_grid
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


func refresh_building_list() -> void:
	_clear_building_list()
	_populate_building_list()


func _on_building_entry_pressed(stack: BuildingStack, btn: BuildingInventoryEntry) -> void:
	if grid_builder == null:
		return
	if grid_builder.selected_info == stack.info:
		grid_builder.deselect()
		_highlight_button(null)
	else:
		grid_builder.select(stack.info)
		_highlight_button(btn)


func _populate_building_list() -> void:
	for stack: BuildingStack in building_inventory.get_stacks():
		const BUILDING_INVENTORY_ENTRY := preload("uid://le1juys13dem")
		var btn: BuildingInventoryEntry = BUILDING_INVENTORY_ENTRY.instantiate()
		btn.setup(stack)
		btn.pressed.connect(_on_building_entry_pressed.bind(stack, btn))
		if grid_builder.selected_info == stack.info:
			_selected_button = btn
			btn.modulate = Color(0.6, 1, 0.6)
		building_list.add_child(btn)
	building_panel.show()


func _highlight_button(btn: Button) -> void:
	if _selected_button != null:
		_selected_button.modulate = Color.WHITE
	_selected_button = btn
	if _selected_button != null:
		_selected_button.modulate = Color(0.6, 1, 0.6)


func _on_selection_changed(info: GridComponentInfo) -> void:
	if info == null:
		_highlight_button(null)
		return
	for btn in building_list.get_children():
		if btn == _selected_button:
			_highlight_button(btn)
			return


func _clear_building_list() -> void:
	for child in building_list.get_children():
		child.queue_free()
	building_panel.hide()
	_selected_button = null
