class_name GridViewer
extends Node2D
## Draws a Grid given to it. Does NOT own or tick the grid — the owner is responsible.
## Used as a debug overlay. Position this node where you want the overlay to appear.
## The owner calls `update_interp(t)` each frame with the tick progress [0,1] so items
## smooth between cells; `bind(grid)` after placement; `mark_dirty()` after layout changes.

var grid: Grid

var _empty_sprite: Texture2D
var _interp_t: float = 1.0

var _bg_cells: Array[Dictionary] = []
var _port_cells: Array[Dictionary] = []
var _comps: Array[Component] = []


func _ready() -> void:
	_empty_sprite = load("uid://6n77yeqc2uc3")
	if grid != null:
		_rebuild_layers()


## Assigns the grid to render and rebuilds caches. Call after the grid layout is set.
func bind(p_grid: Grid) -> void:
	grid = p_grid
	_rebuild_layers()
	queue_redraw()


func update_interp(t: float) -> void:
	_interp_t = t
	queue_redraw()


func mark_dirty() -> void:
	_rebuild_layers()
	queue_redraw()


func _draw() -> void:
	if grid == null:
		return
	for entry in _bg_cells:
		_draw_sprite(entry[&"tex"], entry[&"cell"], entry[&"rot"])
	for comp in _comps:
		if comp.item != null:
			_draw_item(comp, _interp_t)
	for entry in _port_cells:
		_draw_sprite(entry[&"tex"], entry[&"cell"], entry[&"rot"])


## Rebuilds the cached draw layers from `grid`. Call after any placement/removal.
func _rebuild_layers() -> void:
	_bg_cells.clear()
	_port_cells.clear()
	_comps.clear()
	if grid == null:
		return
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
