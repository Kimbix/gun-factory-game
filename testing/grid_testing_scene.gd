extends Node2D

const SAVE_PATH := "user://grid_save.tres"
const SAVE_GRID_INTERFACE := preload("res://interfaces/save_grid_interface.tscn")

@onready var grid_viewer: PlayerGridViewer = $PlayerGridViewer
@onready var player_grid: PlayerGrid = $PlayerGridViewer/PlayerGrid
@onready var debug_builder: DebugPlayerGridBuilder = $DebugLayer/DebugPlayerGridBuilder
@onready var save_grid_button: Button = $DebugLayer/DebugPlayerGridBuilder/VBoxContainer/HBoxContainer/SaveGrid


func _ready() -> void:
	player_grid.initialize_empty()
	player_grid.output_item.connect(_on_output_item)
	save_grid_button.pressed.connect(_on_save_grid_pressed)


func _input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_F1:
			player_grid.tick()
			grid_viewer.queue_redraw()
		KEY_F2:
			debug_builder.visible = not debug_builder.visible
			debug_builder.process_mode = PROCESS_MODE_INHERIT if debug_builder.visible else PROCESS_MODE_DISABLED
		KEY_F3:
			var data := player_grid.to_data()
			var err := ResourceSaver.save(data, SAVE_PATH)
			if err == OK:
				print("Grid saved to %s" % SAVE_PATH)
			else:
				print("Failed to save grid: %d" % err)
		KEY_F4:
			if not ResourceLoader.exists(SAVE_PATH):
				print("No save file found at %s" % SAVE_PATH)
				return
			var data := ResourceLoader.load(SAVE_PATH) as PlayerGridData
			if data == null:
				print("Failed to load save file")
				return
			player_grid.from_data(data)
			grid_viewer.queue_redraw()
			print("Grid loaded from %s" % SAVE_PATH)


func _on_save_grid_pressed() -> void:
	var interface: SaveGridInterface = SAVE_GRID_INTERFACE.instantiate()
	interface.player_grid = player_grid
	InterfaceCanvasLayer.open_window(interface)


func _on_output_item(item: FactoryItem) -> void:
	print("Factory outputted %s" % item.name)
