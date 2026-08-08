class_name GeneratorInterface
extends InterfaceWindow

signal item_pressed(item: FactoryItemInfo)

const ITEM_CATALOGUE := preload("uid://me3tk3q2kkm5")
const ITEM_BUTTON := preload("uid://cq5f74b5ddssl")

@export var close_button: Button

@onready var grid_container: GridContainer = \
		$MarginContainer/VBoxContainer/Content/GridContainer
@onready var current_output: ItemButton = \
		$MarginContainer/VBoxContainer/Content/OutputPanel/VBoxContainer/OutputItem
@onready var time_label: Label = \
		$MarginContainer/VBoxContainer/Content/OutputPanel/VBoxContainer/TimeLabel

var _total_ticks: int = 0


func _ready() -> void:
	for item: FactoryItemInfo in ITEM_CATALOGUE.items:
		var instance: ItemButton = ITEM_BUTTON.instantiate()
		self.grid_container.add_child(instance)
		instance.item = item
		instance.item_pressed.connect(_on_item_pressed)
	close_button.pressed.connect(close_self)


func change_output(item: FactoryItemInfo, total_ticks: int = 0) -> void:
	current_output.item = item
	_total_ticks = total_ticks
	_update_tick_label()


func update_remaining_ticks(remaining: int) -> void:
	time_label.text = "Ticks: %d" % remaining


func _update_tick_label() -> void:
	time_label.text = "Ticks: %d" % _total_ticks


func _on_item_pressed(item: FactoryItemInfo) -> void:
	item_pressed.emit(item)
