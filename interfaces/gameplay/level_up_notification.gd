class_name LevelUpNotification
extends InterfaceWindow

signal reward_chosen(info: GridComponentInfo)

const ALL_PILLARS: Array[GridComponentInfo] = [
	preload("uid://bcal2r5lkeamc"),
	preload("uid://bqpqfr2jxp4t3"),
	preload("uid://s86vmfpi3w15"),
	preload("uid://du6m2qkdv14nq"),
	preload("uid://5h2vu81iay55"),
	preload("uid://bqbpme0t32frd"),
	preload("uid://ow4x6ndkrxfa"),
	preload("uid://cllvvl6vpb1q5"),
	preload("uid://da7gfhppawjyn"),
	preload("uid://bsf5enuerer77"),
	preload("uid://d1t06rym3phod"),
	preload("uid://c80v4vqlnn0sv"),
]

var building_inventory: PlayerBuildingInventory
var on_closed: Callable
var _options: Array[GridComponentInfo] = []


func _ready() -> void:
	reward_chosen.connect(
		func(info: GridComponentInfo) -> void:
			building_inventory.add(info)
			if on_closed:
				on_closed.call()
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
		var boost_text := ""
		if info.config != null and info.config.get("boost_value") != null:
			boost_text = str(info.config.get("boost_value"))
		button.icon = info.texture
		button.text = "%s\n(%s)" % [info.display_name, boost_text]
		button.pressed.connect(_on_option_pressed.bind(i))


func _disconnect_buttons() -> void:
	for b: Button in [%Option1, %Option2, %Option3]:
		for c: Dictionary in b.pressed.get_connections():
			b.pressed.disconnect(c.callable)


func _on_option_pressed(index: int) -> void:
	reward_chosen.emit(_options[index])
	close_self()
