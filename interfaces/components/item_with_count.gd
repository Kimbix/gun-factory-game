class_name ItemWithCount
extends Control

signal item_pressed(item: FactoryItemInfo)

@onready var _texture_rect: TextureRect = $ItemImage
@onready var _count_label: Label = $CountLabel

var _item: FactoryItemInfo
var item: FactoryItemInfo:
	get():
		return _item
	set(v):
		_item = v
		_update_display()

var count: int = 0:
	set(v):
		count = v
		_update_label_deferred()

var required: int = 0:
	set(v):
		required = v
		_update_label_deferred()


func _update_display() -> void:
	if _item == null or _texture_rect == null:
		return
	_texture_rect.texture = _item.texture


func _update_label() -> void:
	if _count_label == null:
		return
	if count > 0:
		_count_label.text = str(count)
		_count_label.add_theme_color_override(&"font_color", Color.WHITE)
		_count_label.visible = true
	elif required > 0:
		_count_label.text = str(required)
		_count_label.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.4))
		_count_label.visible = true
	else:
		_count_label.visible = false


func _ready() -> void:
	_update_display()
	_update_label()
	gui_input.connect(_on_gui_input)


func _update_label_deferred() -> void:
	call_deferred(&"_update_label")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		item_pressed.emit(item)


func _on_mouse_entered() -> void:
	if _item == null:
		return
	var display := _item.display_name if not _item.display_name.is_empty() else _item.name
	TooltipCanvas.show_tooltip(display)


func _on_mouse_exited() -> void:
	TooltipCanvas.hide_tooltip()
