class_name FurnaceInterface
extends InterfaceWindow

@export var close_button: Button
@export var input_display: ItemWithCount
@export var output_display: ItemWithCount
@export var progress_label: Label

var _furnace: Furnace
var furnace: Furnace:
	get():
		return _furnace
	set(v):
		_furnace = v
		generate_ui()


func _ready() -> void:
	close_button.pressed.connect(close_self)


func generate_ui() -> void:
	if furnace == null:
		return
	var cfg := furnace.building.get_info().config as MachineConfig
	output_display.item = cfg.output_item
	output_display.required = 0
	if cfg.input_item != null:
		input_display.item = cfg.input_item
		input_display.required = 1


func update_inventory() -> void:
	if furnace != null:
		input_display.count = furnace.get_input_count()


func update_completion(progress: int, total: int) -> void:
	if progress < 0:
		progress_label.text = "---"
	else:
		progress_label.text = "%d / %d" % [progress, total]
