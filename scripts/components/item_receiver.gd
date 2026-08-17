class_name ItemReceiver
extends FactoryComponent


func tick() -> void:
	pass


func receive_item(_item: FactoryItem) -> void:
	grid.destroy_item(_item)
	grid.output_item(_item)
