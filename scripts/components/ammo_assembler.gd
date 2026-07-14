class_name AmmoAssembler
extends FactoryComponent

const INTERFACE := preload("res://interfaces/ammo_assembler_interface.tscn")

var recipes := load("res://resources/recipes/ammo_assembler_recipes.tres")
var inventory := BlockInventory.new(3)
var recipe: ItemRecipe
var _craft_progress: int = 0


func set_recipe(r: ItemRecipe) -> void:
	recipe = r
	_craft_progress = 0
	_update_overlay_strategy()
	if r != null:
		var allowed: Array[FactoryItemInfo] = []
		for ingredient in r.inputs:
			allowed.append(ingredient.item)

		for slot_idx in inventory.slots.keys():
			if inventory.slots[slot_idx].item_info not in allowed:
				inventory.slots.erase(slot_idx)

		inventory.set_accept_filter(allowed)
	else:
		inventory.slots.clear()
		inventory.set_accept_filter([])


func tick() -> void:
	if recipe == null or not inventory.has_all(recipe.inputs):
		_craft_progress = 0
		_notify_progress(-1)
		return

	if not _can_output():
		_notify_progress(int(_craft_progress * 100.0 / 40.0))
		return

	_craft_progress += 1
	_notify_progress(int(_craft_progress * 100.0 / 40.0))
	if _craft_progress < 40:
		return

	_craft_progress = 0

	for ingredient in recipe.inputs:
		inventory.remove(ingredient.item, ingredient.amount)

	var output_port := _get_available_out_port()
	if output_port == null:
		return

	for output in recipe.outputs:
		if not _can_output_to(output.item, output_port):
			continue
		var where := position + output_port.position + output_port.facing
		var item := FactoryItem.new(output.item, where)
		if recipe is AmmoRecipe:
			var ammo_recipe := recipe as AmmoRecipe
			if ammo_recipe.strategy != null:
				item.shooting_strategy = ammo_recipe.strategy.new()
		grid.place_item(item)


func get_vars() -> Dictionary:
	var slots_data: Array[Dictionary] = []
	for idx in inventory.slots:
		var slot := inventory.slots[idx]
		slots_data.append(
			{
				"index": idx,
				"info": slot.item_info,
				"count": slot.count,
			},
		)
	return {
		&"recipe": recipe,
		&"_inventory_slots": slots_data,
		&"_inventory_accepted": inventory.get_accepted_types(),
		&"_craft_progress": _craft_progress,
	}


func set_var(n: StringName, v: Variant) -> void:
	match n:
		&"recipe":
			set_recipe(v)
		&"_inventory_slots":
			inventory.slots.clear()
			for entry: Dictionary in v:
				var slot := BlockInventory.InventorySlot.new(entry.info as FactoryItemInfo)
				slot.count = entry.count as int
				inventory.slots[entry.index as int] = slot
		&"_inventory_accepted":
			var allowed: Array[FactoryItemInfo] = []
			for item: Variant in v:
				allowed.append(item as FactoryItemInfo)
			inventory.set_accept_filter(allowed)
		_:
			super.set_var(n, v)


func receive_item(item: FactoryItem) -> void:
	inventory.add(item)
	grid.destroy_item(item)


func _update_overlay_strategy() -> void:
	if recipe == null or recipe.outputs.is_empty():
		overlay_strategy = null
		return
	var s := ItemOverlayStrategy.new()
	s.item_info = recipe.outputs[0].item
	overlay_strategy = s


func open_interface() -> void:
	var interface: AmmoAssemblerInterface = INTERFACE.instantiate()
	interface.ammo_assembler = self
	interface.recipes = recipes
	interface.source = self
	if not InterfaceSupervisor.instance.open_interface(
		InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
		interface,
	):
		return
	_progress_interface = interface
	interface.tree_exited.connect(_on_interface_closed)
	_notify_progress(-1)
