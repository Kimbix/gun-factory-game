class_name BuildingInventoryEntry
extends Button

@export var count_label: Label


func setup(stack: BuildingStack) -> void:
	self.icon = stack.info.texture
	count_label.text = "%sx" % stack.count

	var tooltip_str := "%s" % stack.info.display_name
	mouse_entered.connect(TooltipCanvas.show_tooltip.bind(tooltip_str))
	mouse_exited.connect(TooltipCanvas.hide_tooltip)
