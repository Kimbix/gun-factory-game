class_name DebugUI
extends CanvasLayer

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F3 and event.pressed and not event.echo:
		_toggle_stats_debug()


func _toggle_stats_debug() -> void:
	var ui := $StatsDebugUI
	if ui == null:
		return

	if ui.visible:
		ui.hide()
		return

	var player := get_tree().get_first_node_in_group("player") as SimpleCharacter
	if player == null:
		return

	ui.refresh(player)
	ui.show()
