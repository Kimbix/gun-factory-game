class_name GridViewer
extends Node2D
## Draws a Grid and runs its simulation at a steady tick interval for the demo.

@export_range(0, INT8_MAX) var width: int
@export_range(0, INT8_MAX) var height: int
@export_range(0.01, 10.0) var tick_interval: float = 0.3

var grid: Grid

var _empty_sprite: Texture2D

var _timer: float = 0.0

# Cached draw layers, rebuilt whenever grid layout changes (placement/removal).
# Each entry: {cell: Vector2i, tex: Texture2D}.
var _bg_cells: Array[Dictionary] = []
var _port_cells: Array[Dictionary] = []
var _comps: Array[Component] = []


func _ready() -> void:
	_empty_sprite = load("uid://6n77yeqc2uc3")

	var input_type := load("res://assets/components/input_port.tres") as ComponentType
	var output_type := load("res://assets/components/output_port.tres") as ComponentType
	var conveyor_type := load("res://assets/components/conveyor.tres") as ComponentType

	grid = Grid.new()
	grid.build_rect(width, height)
	
	var mid_y: int = int(height / 2.0)
	grid.place(Component.new(input_type), Vector2i(0, mid_y), 0)
	grid.place(Component.new(output_type), Vector2i(width - 1, mid_y), 0)
	for x in range(1, width - 1):
		grid.place(Component.new(conveyor_type), Vector2i(x, mid_y), 0)

	_rebuild_layers()
	queue_redraw()


## Rebuilds the cached draw layers from `grid`. Call after any placement/removal.
## Components are grouped by their `ComponentType.render_layer`. Empty cells go to
## the background layer.
func _rebuild_layers() -> void:
	_bg_cells.clear()
	_port_cells.clear()
	_comps.clear()
	_comps.assign(grid.all_components())
	for cell in grid.contents:
		var comp: Component = grid.component_at(cell)
		if comp == null:
			_bg_cells.append({&"cell": cell, &"tex": _empty_sprite, &"rot": 0})
			continue
		if comp.type == null:
			continue
		var entry := {&"cell": cell, &"tex": comp.type.sprite, &"rot": comp.rotation}
		if comp.type.render_layer == ComponentType.RenderLayer.OVERLAY:
			_port_cells.append(entry)
		else:
			_bg_cells.append(entry)


func _process(delta: float) -> void:
	_timer += delta
	if tick_interval > 0.0:
		while _timer >= tick_interval:
			_timer -= tick_interval
			grid.tick()
	queue_redraw()


func _draw() -> void:
	if grid == null:
		return
	var t: float = clampf(_timer / tick_interval, 0.0, 1.0)

	# Layer 1: background sprites (empty cells + non-port components).
	for entry in _bg_cells:
		_draw_sprite(entry[&"tex"], entry[&"cell"], entry[&"rot"])

	# Layer 2: all items.
	for comp in _comps:
		if comp.item != null:
			_draw_item(comp, t)

	# Layer 3: port sprites on top.
	for entry in _port_cells:
		_draw_sprite(entry[&"tex"], entry[&"cell"], entry[&"rot"])


func _draw_sprite(tex: Texture2D, cell: Vector2i, rot: int) -> void:
	if rot == 0:
		draw_texture(tex, Vector2(cell) * Grid.CELL_SIZE)
		return
	var center := Vector2(cell) * Grid.CELL_SIZE + Vector2.ONE * (Grid.CELL_SIZE / 2.0)
	var tf := Transform2D(rot * (PI / 2.0), center)
	draw_set_transform_matrix(tf)
	draw_texture(tex, -Vector2.ONE * (Grid.CELL_SIZE / 2.0))
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_item(comp: Component, t: float) -> void:
	var from := Vector2(comp.item.from_cell)
	var to := Vector2(comp.origin)
	var visual_pos := from.lerp(to, t) * Grid.CELL_SIZE
	var center := visual_pos + Vector2.ONE * (Grid.CELL_SIZE / 2.0)
	var half := Vector2.ONE * 2.0
	draw_rect(Rect2(center - half, half * 2.0), Color.YELLOW, true)
