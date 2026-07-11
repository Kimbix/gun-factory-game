class_name LevelUpNotification
extends CenterContainer

signal reward_chosen(info: GridComponentInfo)

const ALL_PILLARS: Array[GridComponentInfo] = [
	preload("res://resources/grid_components/max_health_pillar.tres"),
	preload("res://resources/grid_components/move_speed_pillar.tres"),
	preload("res://resources/grid_components/tick_speed_pillar.tres"),
	preload("res://resources/grid_components/health_regen_pillar.tres"),
	preload("res://resources/grid_components/pickup_range_pillar.tres"),
]

var _options: Array[GridComponentInfo] = []


func _ready() -> void:
	reward_chosen.connect(
		func(info: GridComponentInfo) -> void:
			var player := GameSupervisor.instance.get_player()
			player.building_inventory.add(info)
			GameSupervisor.instance.unpause_gameplay()
	)

	show_options()


func show_options() -> void:
	var pool: Array[GridComponentInfo] = ALL_PILLARS.duplicate()
	pool.shuffle()
	_options = pool.slice(0, 3)

	_disconnect_buttons()
	_configure_buttons()
	show()


func _configure_buttons() -> void:
	var buttons: Array[Button] = [%Option1, %Option2, %Option3]
	for i in 3:
		var info := _options[i]
		var button := buttons[i]
		button.icon = info.texture
		button.text = "%s\n(%s)" % [info.display_name, info.boost_value]
		button.pressed.connect(_on_option_pressed.bind(i))


func _disconnect_buttons() -> void:
	for b: Button in [%Option1, %Option2, %Option3]:
		for c: Dictionary in b.pressed.get_connections():
			b.pressed.disconnect(c.callable)


func _on_option_pressed(index: int) -> void:
	reward_chosen.emit(_options[index])
	hide()
