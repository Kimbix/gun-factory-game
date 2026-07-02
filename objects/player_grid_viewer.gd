class_name PlayerGridViewer
extends Node2D

@export var grid: PlayerGrid = null
@export var view_ports: bool


func _draw() -> void:
	if grid == null:
		return

	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		draw_texture(grid.get_floor_texture(v), v * PlayerGrid.GRID_TEXTURE_SIZE)

	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		var to_draw: Texture2D = grid.get_building_texture(v)
		if to_draw == null:
			continue
		var rot := grid.get_building_rotation(v)
		if rot != 0:
			var center := Vector2(v * PlayerGrid.GRID_TEXTURE_SIZE) + Vector2.ONE * (PlayerGrid.GRID_TEXTURE_SIZE / 2.0)
			var radians := 0.0
			match rot:
				1: # CLOCKWISE
					radians = PI / 2.0
				2: # COUNTERCLOCKWISE
					radians = -PI / 2.0
				3: # FLIPPED
					radians = PI
			draw_set_transform(center, radians, Vector2.ONE)
			draw_texture(to_draw, -Vector2.ONE * (PlayerGrid.GRID_TEXTURE_SIZE / 2.0))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_texture(to_draw, v * PlayerGrid.GRID_TEXTURE_SIZE)

	for i: int in grid.get_item_count():
		var texture := grid.get_item_texture(i)
		var pos := grid.get_item_position(i) * PlayerGrid.GRID_TEXTURE_SIZE
		draw_texture(texture, pos)

	if view_ports:
		_draw_ports()


func _draw_ports() -> void:
	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		if not grid.has_building(v):
			continue

		var ports: Array[Port] = grid.get_building_ports(v)
		if ports.size() == 0:
			continue

		var half_block := PlayerGrid.GRID_TEXTURE_SIZE / 2.0
		var offset := Vector2.ONE * half_block
		var cell_center: Vector2 = Vector2(v * PlayerGrid.GRID_TEXTURE_SIZE) + offset
		for p: Port in ports:
			var is_out := p.mode == Port.PortMode.OUT
			var draw_pos := cell_center + p.facing * half_block
			var color := Color(1, 0, 0, .5) if is_out else Color(0, 1, 0, .5)
			draw_circle(draw_pos, .5, color)
