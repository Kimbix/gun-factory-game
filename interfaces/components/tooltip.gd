class_name Tooltip
extends PanelContainer

@onready var label: Label = $Label


## Sets the tooltip text content.
func set_text(text: String) -> void:
	label.text = text
