class_name ConveyorBelt
extends FactoryComponent

var items: Array[FactoryItem] = []


func tick() -> void:
	for i: FactoryItem in items.duplicate():
		var new_rect := i.rect
		new_rect.position += Vector2.RIGHT * .05

		if new_rect.position.x + new_rect.size.x * .5 < rect.position.x + rect.size.x:
			i.position += Vector2.RIGHT * .05
			continue

		var p := _get_available_out_port()
		if p == null:
			continue # There are no available ports :( 
		var build := grid.get_building(position + p.position + p.facing)
		# If there is a building at the end of the conveyor, hand the item to it
		if build != null and _can_output():
			items.erase(i) # We no longer "own" the item
			build.receive_item(i)


func receive_item(item: FactoryItem) -> void:
	items.append(item)
