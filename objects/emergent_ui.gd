class_name EmergentUI
extends CanvasLayer

signal resume_requested


func show_level_up() -> void:
	%LevelUpNotification.show_options()


func _ready() -> void:
	%LevelUpNotification.reward_chosen.connect(_on_reward_chosen)


func _on_reward_chosen(info: GridComponentInfo) -> void:
	var player := get_tree().get_first_node_in_group("player") as SimpleCharacter
	if player == null:
		return
	player.building_inventory.add(info)
	resume_requested.emit()
