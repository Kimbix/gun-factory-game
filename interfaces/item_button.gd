class_name ItemButton
extends Button

signal item_pressed(item: FactoryItemInfo)

var _item: FactoryItemInfo
var item: FactoryItemInfo:
	get():
		return _item
	set(v):
		_item = v
		if _item != null:
			texture_rect.texture = _item.texture
			var display := _item.display_name if not _item.display_name.is_empty() else _item.name
			tooltip_text = display
			print("set tooltip: ", display, " rect: ", get_rect())
var texture:
	get():
		return texture_rect.texture
var texture_rect: TextureRect


func _ready() -> void:
	texture_rect = $ItemImage
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pressed.connect(_on_pressed)
	print("ready rect: ", get_rect(), " size: ", size)


func _on_pressed() -> void:
	item_pressed.emit(item)
