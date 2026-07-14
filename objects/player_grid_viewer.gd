class_name PlayerGridViewer
extends Node2D

const GRID_TEXTURE_SIZE := 16.0

@export var grid: PlayerGrid = null
@export var view_ports: bool
@export var building_overlay: bool
@export var overlay_font: Font


func _draw() -> void:
	if grid == null:
		return

	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		draw_texture(grid.get_floor_texture(v), v * GRID_TEXTURE_SIZE)

	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		var to_draw: Texture2D = grid.get_building_texture(v)
		if to_draw == null:
			continue
		var rot := grid.get_building_rotation(v)
		if rot != 0:
			var center := Vector2(v * PlayerGridViewer.GRID_TEXTURE_SIZE) + Vector2.ONE * (PlayerGridViewer.GRID_TEXTURE_SIZE / 2.0)
			var radians := 0.0
			match rot:
				FactoryBuilding.Rotation.CLOCKWISE:
					radians = PI / 2.0
				FactoryBuilding.Rotation.COUNTERCLOCKWISE:
					radians = -PI / 2.0
				FactoryBuilding.Rotation.FLIPPED:
					radians = PI
			draw_set_transform(center, radians, Vector2.ONE)
			draw_texture(to_draw, -Vector2.ONE * (PlayerGridViewer.GRID_TEXTURE_SIZE / 2.0))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_texture(to_draw, v * PlayerGridViewer.GRID_TEXTURE_SIZE)

	for i: int in grid.get_item_count():
		var texture := grid.get_item_texture(i)
		var pos := grid.get_item_position(i) * PlayerGridViewer.GRID_TEXTURE_SIZE
		draw_texture(texture, pos)

	if view_ports:
		_draw_ports()

	if building_overlay:
		_draw_overlays()


func get_width() -> float:
	return grid.dimensions.x * GRID_TEXTURE_SIZE * self.scale.x


func get_height() -> float:
	return grid.dimensions.y * GRID_TEXTURE_SIZE * self.scale.y


## Function used to set the size of the viewer, regardless of the grid dimensions
func set_final_size(size: Vector2) -> void:
	var curr_size := grid.dimensions * GRID_TEXTURE_SIZE * self.scale
	var new_scale := size / curr_size
	self.scale *= new_scale
	print(new_scale)


func _draw_overlays() -> void:
	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		if not grid.has_building(v):
			continue
		var building := grid.get_building(v)
		if building.position != v:
			continue
		var behaviour := building.behaviour
		if behaviour == null:
			continue
		var strategy := behaviour.overlay_strategy as OverlayStrategy
		if strategy == null:
			continue
		var center := Vector2(v * GRID_TEXTURE_SIZE) + Vector2.ONE * (GRID_TEXTURE_SIZE / 2.0)
		for layer: Dictionary in strategy.get_layers():
			var tex: Texture2D = layer.get("texture") as Texture2D
			if tex != null:
				draw_texture(tex, center - tex.get_size() / 2.0)
				continue
			var text: String = layer.get("text", "")
			if text.is_empty():
				continue
			var font := overlay_font
			if font == null:
				font = ThemeDB.fallback_font
			var font_size := layer.get("font_size", 8) as int
			var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			var text_pos := center - text_size / 2.0
			draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)


func _draw_ports() -> void:
	for v: Vector2i in VectorTools.vector2i_range(grid.dimensions):
		if not grid.has_building(v):
			continue

		var ports: Array[Port] = grid.get_building_ports(v)
		if ports.size() == 0:
			continue

		var half_block := PlayerGridViewer.GRID_TEXTURE_SIZE / 2.0
		var offset := Vector2.ONE * half_block
		var cell_center: Vector2 = Vector2(v * PlayerGridViewer.GRID_TEXTURE_SIZE) + offset
		for p: Port in ports:
			var is_out := p.mode == Port.PortMode.OUT
			var draw_pos := cell_center + p.facing * half_block
			var color := Color(1, 0, 0, .5) if is_out else Color(0, 1, 0, .5)
			draw_circle(draw_pos, .5, color)
