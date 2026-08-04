class_name LootBoxTable
extends Resource
## A weighted collection of [LootBoxEntry]s. [method pick] returns a random
## [PackedScene] from the table, chosen with probability proportional to
## each entry's [member LootBoxEntry.weight]. Entries with a null [member
## LootBoxEntry.scene] or a non-positive weight are skipped.

@export var entries: Array[LootBoxEntry] = []


func pick() -> PackedScene:
	var total_weight := 0.0
	for entry in entries:
		if entry == null or entry.scene == null or entry.weight <= 0.0:
			continue
		total_weight += entry.weight

	if total_weight <= 0.0:
		return null

	var roll := randf() * total_weight
	var cumulative := 0.0
	for entry in entries:
		if entry == null or entry.scene == null or entry.weight <= 0.0:
			continue
		cumulative += entry.weight
		if roll < cumulative:
			return entry.scene

	return null
