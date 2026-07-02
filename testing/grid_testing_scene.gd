extends Node2D

@export var ticks_per_second: int = 20

var _tick_timer: float = 0.0

@onready var grid_viewer: PlayerGridViewer = $PlayerGridViewer
@onready var player_grid: PlayerGrid = $PlayerGridViewer/PlayerGrid


func _ready() -> void:
	const CONVEYOR_INFO := preload("uid://cxaf6asblr1t7")
	const GENERATOR_INFO := preload("uid://d1wu3w33a0ds1")
	const RECEIVER_INFO := preload("uid://djspgv1yqiaky")
	const BULLET_CASING_INFO := preload("uid://c4wf626ege7cx")

	player_grid.initialize_empty()
	player_grid.place_building(GENERATOR_INFO, Vector2i(0, 4))
	player_grid.place_building(RECEIVER_INFO, Vector2i(9, 4))
	player_grid.set_building_var("generating", BULLET_CASING_INFO, Vector2i(0, 4))
	for i: int in range(1, 9):
		player_grid.place_building(CONVEYOR_INFO, Vector2i(i, 4))

	player_grid.output_item.connect(_on_output_item)


func _process(delta: float) -> void:
	if ticks_per_second <= 0:
		return
	_tick_timer += delta
	var interval := 1.0 / ticks_per_second
	while _tick_timer >= interval:
		_tick_timer -= interval
		player_grid.tick()
	grid_viewer.queue_redraw()


func _input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_F1:
			player_grid.tick()
			grid_viewer.queue_redraw()


func _on_output_item(item: FactoryItem) -> void:
	print("Factory outputted %s" % item.name)
