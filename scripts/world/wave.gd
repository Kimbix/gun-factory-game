class_name Wave
extends Resource

@export var entries: Array[SpawnEntry] = []


func total_count() -> int:
	var total := 0
	for e in entries:
		total += e.count
	return total
