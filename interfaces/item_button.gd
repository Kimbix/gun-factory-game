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
			_update_display()
var texture:
	get():
		return texture_rect.texture if texture_rect != null else null
var texture_rect: TextureRect


func _update_display() -> void:
	if _item == null or texture_rect == null:
		return
	texture_rect.texture = _item.texture
	var display := _item.display_name if not _item.display_name.is_empty() else _item.name
	tooltip_text = display


func _ready() -> void:
	texture_rect = $ItemImage
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pressed.connect(_on_pressed)
	_update_display()


func _on_pressed() -> void:
	item_pressed.emit(item)
