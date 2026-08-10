class_name MetalProcessorInterface
extends RecipeMachineInterface

var metal_processor: MetalProcessor:
	get():
		return machine
	set(v):
		machine = v
		generate_ui()


func _get_recipe() -> ItemRecipe:
	return metal_processor.recipe if metal_processor != null else null


func _set_recipe(r: ItemRecipe) -> void:
	metal_processor.set_recipe(r)


func _get_inventory_count(item: FactoryItemInfo) -> int:
	if metal_processor == null:
		return 0
	if item.name == &"lead_plate":
		return metal_processor.lead_plates
	return 0
