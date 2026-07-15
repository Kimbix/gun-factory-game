class_name BuildingUI
extends BaseInterface

var _building := false

@export var player_grid: PlayerGrid
@export var grid_builder: GridBuilder
var building_inventory: PlayerBuildingInventory

@onready var player_grid_viewer := $PlayerGridViewer
@onready var building_panel := $BuildingInventoryPanel
@onready var building_list := %BuildingList
@onready var shop_panel := $ShopPanel


func open_building_interface() -> void:
	if _building:
		return
	open_factory_interface()
	shop_panel.building_inventory = building_inventory
	shop_panel.refresh()
	shop_panel.show()
	if not building_inventory.changed.is_connected(refresh_building_list):
		building_inventory.changed.connect(refresh_building_list)
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
	_clear_building_list()
	shop_panel.hide()
	_building = false


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


func _populate_building_list() -> void:
	for stack in building_inventory.get_stacks():
		var btn := Button.new()
		btn.icon = stack.info.texture
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(64, 64)
		btn.size_flags_horizontal = 0
		btn.pressed.connect(
			func() -> void:
				if grid_builder == null:
					return
				if grid_builder.selected_info == stack.info:
					grid_builder.deselect()
				else:
					grid_builder.select(stack.info)
		)

		var count_label := Label.new()
		count_label.text = "x" + str(stack.count)
		count_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		count_label.set_offset(SIDE_RIGHT, -4)
		count_label.set_offset(SIDE_BOTTOM, -4)
		btn.add_child(count_label)

		building_list.add_child(btn)
	building_panel.show()


func refresh_building_list() -> void:
	_clear_building_list()
	_populate_building_list()


func _clear_building_list() -> void:
	for child in building_list.get_children():
		child.queue_free()
	building_panel.hide()
