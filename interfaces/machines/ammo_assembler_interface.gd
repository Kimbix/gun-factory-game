class_name AmmoAssemblerInterface
extends RecipeMachineInterface

var ammo_assembler: AmmoAssembler:
	get():
		return machine
	set(v):
		machine = v
		generate_ui()


func _get_recipe() -> ItemRecipe:
	return ammo_assembler.recipe if ammo_assembler != null else null


func _set_recipe(r: ItemRecipe) -> void:
	ammo_assembler.set_recipe(r)


func _get_inventory_count(item: FactoryItemInfo) -> int:
	if ammo_assembler == null:
		return 0
	var total := 0
	for slot in ammo_assembler.inventory.slots.values():
		if slot.item_info == item:
			total += slot.count
	return total
