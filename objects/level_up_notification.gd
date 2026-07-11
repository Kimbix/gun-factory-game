extends CenterContainer

signal resume_requested


func _ready() -> void:
	$Button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	hide()
	resume_requested.emit()
