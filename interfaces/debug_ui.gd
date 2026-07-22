class_name DebugUI
extends BaseInterface

func toggle_stats_debug() -> void:
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
