class_name ItemButton
extends Button

signal item_pressed(item: FactoryItemInfo)

var item: FactoryItemInfo:
	get():
		return item
	set(v):
		item = v
		texture_rect.texture = item.texture
var texture:
	get():
		return texture_rect.texture
var texture_rect: TextureRect


func _ready() -> void:
	texture_rect = $ItemImage
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	item_pressed.emit(item)
