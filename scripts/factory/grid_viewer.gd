class_name GridViewer
extends Node2D
## Draws a Grid given to it. Does NOT own or tick the grid — the owner is responsible.
## Used as a debug overlay. Position this node where you want the overlay to appear.
## The owner calls `update_interp(t)` each frame with the tick progress [0,1] so items
## smooth between cells; `bind(grid)` after placement; `mark_dirty()` after layout changes.

var grid: Grid
var cursor_cell: Vector2i = Vector2i(-1, -1)
var inventory: Inventory
var selected_slot: int = 0
var preview_rotation: int = 0
var inventory_y: int = 28

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
	if cursor_cell.x >= 0 and grid != null and grid.has_cell(cursor_cell):
		var pos := Vector2(cursor_cell) * Grid.CELL_SIZE
		draw_rect(Rect2(pos, Vector2.ONE * Grid.CELL_SIZE), Color(1, 1, 1, 0.3), true)
		draw_rect(Rect2(pos, Vector2.ONE * Grid.CELL_SIZE), Color.WHITE, false, 1.0)
		if grid.is_empty(cursor_cell) and inventory != null:
			var slot := inventory.get_slot(selected_slot)
			if slot != null and not slot.is_empty() and slot.component_type.sprite != null:
				var tex := slot.component_type.sprite
				var cell := Vector2.ONE * Grid.CELL_SIZE
				if preview_rotation == 0:
					draw_texture_rect(tex, Rect2(pos, cell), false, Color(0.6, 0.6, 0.6, 0.6))
				else:
					var center := pos + cell / 2.0
					var half := cell / 2.0
					draw_set_transform(center, preview_rotation * (PI / 2.0))
					draw_texture_rect(tex, Rect2(-half, cell), false, Color(0.6, 0.6, 0.6, 0.6))
					draw_set_transform(Vector2.ZERO, 0.0)
	if inventory == null:
		return
	var slot_pos := Vector2(0, inventory_y)
	var slot_size := Vector2.ONE * Grid.CELL_SIZE
	var font := ThemeDB.fallback_font
	var font_size := 4
	var gap := 2
	for i in Inventory.MAX_SLOTS:
		var rect := Rect2(slot_pos + Vector2(i * (Grid.CELL_SIZE + gap), 0), slot_size)
		var slot := inventory.get_slot(i)
		if slot.is_empty():
			draw_texture(_empty_sprite, rect.position)
		else:
			draw_texture(slot.component_type.sprite, rect.position)
			var amt := "x%d" % slot.count
			var amt_w := font.get_string_size(amt, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			draw_string(font, rect.position + Vector2(slot_size.x - amt_w, slot_size.y - 1), amt, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var num := str(i + 1)
		var num_w := font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(font, rect.position + Vector2(slot_size.x - num_w, font_size), num, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if i == selected_slot:
			draw_rect(rect, Color.YELLOW, false, 1.0)


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
