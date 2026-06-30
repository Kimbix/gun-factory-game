class_name GridViewer
extends Node2D

## Draws a Grid and runs its simulation at a steady tick interval for the demo.

@export_range(0, INT8_MAX) var width: int
@export_range(0, INT8_MAX) var height: int
@export var tick_interval: float = 0.3

var grid: Grid

var _empty_sprite: Texture2D
var _input_port_sprite: Texture2D
var _output_port_sprite: Texture2D
var _conveyor_sprite: Texture2D

var _timer: float = 0.0


func _ready() -> void:
	_empty_sprite = load("res://assets/components/spr_emptyGridSpot.png")
	_input_port_sprite = load("res://assets/components/spr_inputPort.png")
	_output_port_sprite = load("res://assets/components/spr_outputPort.png")
	_conveyor_sprite = load("res://assets/components/spr_conveyor.png")

	grid = Grid.new()
	grid.build_rect(width, height)

	var mid_y: int = height / 2
	var input_type := _build_type(_input_port_sprite, &"input_port", &"bullet")
	var output_type := _build_type(_output_port_sprite, &"output_port", &"finished_round")
	var conveyor_type := _build_type(_conveyor_sprite, &"conveyor")

	grid.place(Component.new(input_type), Vector2i(0, mid_y), 0)
	grid.place(Component.new(output_type), Vector2i(width - 1, mid_y), 0)
	for x in range(1, width - 1):
		grid.place(Component.new(conveyor_type), Vector2i(x, mid_y), 0)

	queue_redraw()


func _process(delta: float) -> void:
	_timer += delta
	while _timer >= tick_interval:
		_timer -= tick_interval
		grid.tick()
	queue_redraw()


func _draw() -> void:
	if grid == null:
		return
	var t: float = clampf(_timer / tick_interval, 0.0, 1.0)

	# Pass 1: sprites + items-above-conveyors (items render ON TOP of conveyors).
	for cell in grid.contents:
		var comp: Component = grid.component_at(cell)
		var pos := Vector2(cell) * Grid.CELL_SIZE
		var tex: Texture2D = comp.type.sprite if comp != null and comp.type != null else _empty_sprite
		draw_texture(tex, pos)
		if comp != null and comp.type != null and comp.type.kind == &"conveyor" and comp.item != null:
			_draw_item(comp, t)

	# Pass 2: items-BEHIND-ports (items render UNDER ports).
	# Since port sprites were already drawn, the visual stacking is "port over item"
	# only if we draw the port again here after the item. Redraw port sprites for ports
	# that currently own an item so the item pokes out from underneath.
	for cell in grid.contents:
		var comp: Component = grid.component_at(cell)
		if comp == null or comp.type == null:
			continue
		var is_port := comp.type.kind == &"input_port" or comp.type.kind == &"output_port"
		if not is_port or comp.item == null:
			continue
		_draw_item(comp, t)
		draw_texture(comp.type.sprite, Vector2(comp.origin) * Grid.CELL_SIZE)


func _draw_item(comp: Component, t: float) -> void:
	var from := Vector2(comp.item.from_cell)
	var to := Vector2(comp.origin)
	var visual_pos := from.lerp(to, t) * Grid.CELL_SIZE
	var center := visual_pos + Vector2.ONE * (Grid.CELL_SIZE / 2.0)
	var half := Vector2.ONE * 2.0
	draw_rect(Rect2(center - half, half * 2.0), Color.YELLOW, true)


func _build_type(sprite: Texture2D, kind: StringName, material: StringName = &"") -> ComponentType:
	var t := ComponentType.new()
	t.sprite = sprite
	t.kind = kind
	t.material = material
	return t
