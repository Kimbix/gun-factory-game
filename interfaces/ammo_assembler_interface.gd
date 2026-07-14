class_name AmmoAssemblerInterface
extends RecipeMachineInterface

var ammo_assembler: AmmoAssembler:
	get():
		return _machine
	set(v):
		_machine = v
		generate_ui()


func _get_recipe() -> ItemRecipe:
	return ammo_assembler.recipe if ammo_assembler != null else null


func _set_recipe(r: ItemRecipe) -> void:
	ammo_assembler.set_recipe(r)
