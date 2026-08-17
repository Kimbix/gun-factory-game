class_name ShopEntryUI
extends Button

@onready var _entry_texture: TextureRect = $Container/EntryImage
@onready var _stock_count_label: Label = $Container/InformationContainer/StockAndPrice/StockCount
@onready var _item_name_label: Label = $Container/InformationContainer/ItemName
@onready var _price_label: Label = $Container/InformationContainer/StockAndPrice/Price


func set_rarity(rarity: Rarity) -> void:
	_stock_count_label.add_theme_color_override("font_color", rarity.color)
	_item_name_label.add_theme_color_override("font_color", rarity.color)
	_price_label.add_theme_color_override("font_color", rarity.color)


func set_item(item: ShopItem) -> void:
	_setup()
	set_rarity(item.rarity)
	_entry_texture.texture = item.item.texture
	_item_name_label.text = item.item.display_name
	_price_label.text = "%sg" % str(item.base_price)
	_stock_count_label.text = "Stock: %sx" % str(item.stock)


func _setup() -> void:
	_entry_texture = $Container/EntryImage
	_stock_count_label = $Container/InformationContainer/StockAndPrice/StockCount
	_item_name_label = $Container/InformationContainer/ItemName
	_price_label = $Container/InformationContainer/StockAndPrice/Price
