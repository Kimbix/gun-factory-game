class_name DebugUI
extends BaseInterface


func toggle_stats_debug(player: SimpleCharacter) -> void:
	var ui := $StatsDebugUI
	if ui == null:
		return

	if ui.visible:
		ui.hide()
		return

	ui.refresh(player)
	ui.show()
