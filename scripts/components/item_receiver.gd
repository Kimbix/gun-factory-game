class_name ItemReceiver
extends FactoryComponent

func tick() -> void:
	pass


func receive_item(_item: FactoryItem) -> void:
	grid.destroy_item(_item)
	_notify("output_item", [_item])
