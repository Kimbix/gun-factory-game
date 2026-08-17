class_name BuildingInventoryEntry
extends Button

@export var count_label: Label


func setup(stack: BuildingStack) -> void:
	self.icon = stack.info.texture
	count_label.text = "%sx" % stack.count
