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
