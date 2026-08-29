class_name EnhancementCatalogue
extends Resource

@export var entries: Array[EnhancementEntry] = []


func find_entry(item_name: StringName) -> EnhancementEntry:
	for entry in entries:
		if entry.item_name == item_name:
			return entry
	return null
