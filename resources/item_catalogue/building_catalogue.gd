class_name BuildingCatalogue
extends Resource

@export var buildings: Array[GridComponentInfo]


func get_texture(id: int) -> Texture2D:
	if buildings.size() <= id:
		return null
	return buildings[id].texture
