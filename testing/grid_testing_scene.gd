extends Node2D

@onready var grid_viewer: PlayerGridViewer = $PlayerGridViewer
@onready var player_grid: PlayerGrid = $PlayerGridViewer/PlayerGrid


func _ready() -> void:
	const CONVEYOR_INFO := preload("uid://cxaf6asblr1t7")
	const GENERATOR_INFO := preload("uid://d1wu3w33a0ds1")
	const RECEIVER_INFO := preload("uid://djspgv1yqiaky")
	const BULLET_CASING_INFO := preload("uid://c4wf626ege7cx")

	player_grid.initialize_empty()

	player_grid.place_building(GENERATOR_INFO, Vector2i(0, 0), FactoryBuilding.Rotation.NORMAL)
	player_grid.place_building(CONVEYOR_INFO, Vector2i(1, 0), FactoryBuilding.Rotation.NORMAL)
	player_grid.place_building(RECEIVER_INFO, Vector2i(2, 0), FactoryBuilding.Rotation.NORMAL)
	player_grid.set_building_var("generating", BULLET_CASING_INFO, Vector2i(0, 0))

	player_grid.place_building(GENERATOR_INFO, Vector2i(2, 1), FactoryBuilding.Rotation.FLIPPED)
	player_grid.place_building(CONVEYOR_INFO, Vector2i(1, 1), FactoryBuilding.Rotation.FLIPPED)
	player_grid.place_building(RECEIVER_INFO, Vector2i(0, 1), FactoryBuilding.Rotation.FLIPPED)
	player_grid.set_building_var("generating", BULLET_CASING_INFO, Vector2i(2, 1))

	player_grid.place_building(GENERATOR_INFO, Vector2i(3, 0), FactoryBuilding.Rotation.CLOCKWISE)
	player_grid.place_building(CONVEYOR_INFO, Vector2i(3, 1), FactoryBuilding.Rotation.CLOCKWISE)
	player_grid.place_building(RECEIVER_INFO, Vector2i(3, 2), FactoryBuilding.Rotation.CLOCKWISE)
	player_grid.set_building_var("generating", BULLET_CASING_INFO, Vector2i(3, 0))

	player_grid.place_building(GENERATOR_INFO, Vector2i(4, 2), FactoryBuilding.Rotation.COUNTERCLOCKWISE)
	player_grid.place_building(CONVEYOR_INFO, Vector2i(4, 1), FactoryBuilding.Rotation.COUNTERCLOCKWISE)
	player_grid.place_building(RECEIVER_INFO, Vector2i(4, 0), FactoryBuilding.Rotation.COUNTERCLOCKWISE)
	player_grid.set_building_var("generating", BULLET_CASING_INFO, Vector2i(4, 2))

	player_grid.output_item.connect(_on_output_item)


func _input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_F1:
			player_grid.tick()
			grid_viewer.queue_redraw()


func _on_output_item(item: FactoryItem) -> void:
	print("Factory outputted %s" % item.name)
