class_name ItemGenerator
extends FactoryComponent

var generating: FactoryItemInfo:
	set(v):
		generating = v
		_precompute_offsets()
		_cooldown = 0
var _cooldown: int = 0
var _offsets: Dictionary = { }


func tick() -> void:
	if generating == null:
		return

	if _cooldown > 0:
		_cooldown -= 1
		return
	if not _can_output():
		return
	var output_port := _get_available_out_port()
	if output_port == null:
		return
	var where_to: Vector2 = position + output_port.position + output_port.facing
	grid.place_item(generating, where_to + _offsets[rotation])
	_cooldown = 40


func _precompute_offsets() -> void:
	if generating == null:
		return
	_offsets[FactoryBuilding.Rotation.NORMAL] = Vector2.DOWN * .5 + Vector2.UP * generating.grid_size.y * .5
	_offsets[FactoryBuilding.Rotation.CLOCKWISE] = Vector2.RIGHT * .5 + Vector2.LEFT * generating.grid_size.x * .5
	_offsets[FactoryBuilding.Rotation.COUNTERCLOCKWISE] = Vector2.DOWN + Vector2.UP * generating.grid_size.y + Vector2.RIGHT * .5 + Vector2.LEFT * generating.grid_size.x * .5
	_offsets[FactoryBuilding.Rotation.FLIPPED] = Vector2.RIGHT + Vector2.LEFT * generating.grid_size.x + Vector2.DOWN * .5 + Vector2.UP * generating.grid_size.y * .5
