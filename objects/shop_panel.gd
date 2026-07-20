class_name ShopPanel
extends PanelContainer

var catalogue: ShopCatalogue
var building_inventory: PlayerBuildingInventory
var _slots: Array[Dictionary] = []
var _reroll_count: int = 0

@onready var _gold_label: Label = %GoldLabel
@onready var _slot_container: VBoxContainer = %SlotContainer
@onready var _reroll_button: Button = %RerollButton
@onready var _reroll_cost_label: Label = %RerollCostLabel
@onready var _empty_label: Label = %EmptyLabel


static func get_reroll_cost(reroll_count: int) -> int:
	return 5 + reroll_count * 5


static func _get_item_price(shop_item: ShopItem, _times_purchased: int) -> int:
	return shop_item.base_price


func _ready() -> void:
	catalogue = load("uid://dpko52oiv2rwe")
	_reroll_button.pressed.connect(_on_reroll_pressed)


func refresh() -> void:
	_reroll_count = 0
	if _slots.is_empty():
		_pick_random_items()
	_update_ui()


func _pick_random_items() -> void:
	_slots.clear()
	var available: Array[ShopItem] = []
	for shop_item: ShopItem in catalogue.items:
		if shop_item.stock > 0:
			available.append(shop_item)

	if available.is_empty():
		return

	var pool: Array[ShopItem] = available.duplicate()
	var picked: Array[ShopItem] = []

	for i in range(min(3, pool.size())):
		var total_weight: float = 0.0
		for si: ShopItem in pool:
			total_weight += si.rarity.weight

		var roll: float = randf_range(0.0, total_weight)
		var cumulative: float = 0.0
		var chosen_idx: int = 0
		for j in range(pool.size()):
			cumulative += pool[j].rarity.weight
			if roll <= cumulative:
				chosen_idx = j
				break

		chosen_idx = mini(chosen_idx, pool.size() - 1)
		var chosen: ShopItem = pool[chosen_idx]
		pool.remove_at(chosen_idx)
		picked.append(chosen)

	for si: ShopItem in picked:
		_slots.append({ "item": si, "stock": si.stock })


func _update_ui() -> void:
	var player := _get_player()
	var gold: int = 0
	if player != null:
		gold = player.level_system.gold
	_gold_label.text = "Gold: %d" % gold

	for child: Node in _slot_container.get_children():
		child.queue_free()

	var has_available: bool = false
	for slot: Dictionary in _slots:
		if slot.stock <= 0:
			continue
		has_available = true
		var si: ShopItem = slot.item
		var price: int = _get_item_price(si, 0)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 32)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var icon := TextureRect.new()
		icon.texture = si.item.texture
		icon.custom_minimum_size = Vector2(24, 24)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		hbox.add_child(icon)

		var name_label := Label.new()
		name_label.text = si.item.display_name
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 12)
		hbox.add_child(name_label)

		var details := Label.new()
		details.text = "%dg  (x%d)" % [price, slot.stock]
		details.add_theme_color_override("font_color", si.rarity.color)
		details.add_theme_font_size_override("font_size", 11)
		details.size_flags_horizontal = Control.SIZE_SHRINK_END
		hbox.add_child(details)

		btn.add_child(hbox)

		var can_afford: bool = player != null and player.level_system.gold >= price
		btn.disabled = not can_afford

		btn.pressed.connect(_on_slot_pressed.bind(slot))
		_slot_container.add_child(btn)

	var cost: int = get_reroll_cost(_reroll_count)
	if has_available:
		_reroll_button.text = "Reroll — %dg" % cost
		_reroll_cost_label.text = ""
		_empty_label.hide()
	else:
		_reroll_button.text = "Reroll — %dg" % cost
		_reroll_cost_label.text = ""
		_empty_label.show()

	var can_reroll: bool = player != null and player.level_system.gold >= cost
	_reroll_button.disabled = not can_reroll


func _on_slot_pressed(slot: Dictionary) -> void:
	var player := _get_player()
	if player == null:
		return
	var si: ShopItem = slot.item
	var price: int = _get_item_price(si, 0)
	if not player.level_system.spend_gold(price):
		return
	building_inventory.add(si.item, 1)
	slot.stock -= 1
	_update_ui()


func _on_reroll_pressed() -> void:
	var player := _get_player()
	if player == null:
		return
	var cost: int = get_reroll_cost(_reroll_count)
	if not player.level_system.spend_gold(cost):
		return
	_reroll_count += 1
	_pick_random_items()
	_update_ui()


func _get_player() -> SimpleCharacter:
	return get_tree().get_first_node_in_group("player") as SimpleCharacter
