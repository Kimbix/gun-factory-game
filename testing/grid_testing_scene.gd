extends Node2D

@onready var grid_viewer: PlayerGridViewer = $PlayerGridViewer
@onready var player_grid: PlayerGrid = $PlayerGridViewer/PlayerGrid


func _ready() -> void:
	player_grid.initialize_empty()
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
