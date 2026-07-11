class_name GeneratorInterface
extends PanelContainer

signal item_pressed(item: FactoryItemInfo)

const ITEM_CATALOGUE := preload("uid://me3tk3q2kkm5")
const ITEM_BUTTON := preload("uid://cq5f74b5ddssl")

@export var close_button: Button

@onready var grid_container: GridContainer = $GridContainer
@onready var current_output: ItemButton = $ItemButton


func _ready() -> void:
	for item: FactoryItemInfo in ITEM_CATALOGUE.items:
		var instance: ItemButton = ITEM_BUTTON.instantiate()
		self.grid_container.add_child(instance)
		instance.item = item
		instance.item_pressed.connect(_on_item_pressed)
	close_button.pressed.connect(_on_close)


func change_output(item: FactoryItemInfo) -> void:
	current_output.item = item


func _on_close() -> void:
	InterfaceCanvasLayer.close_window(self)


func _on_item_pressed(item: FactoryItemInfo) -> void:
	item_pressed.emit(item)
