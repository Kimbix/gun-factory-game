class_name ItemGenerator
extends FactoryComponent

const INTERFACE := preload("uid://c8wqyeagxk100")

var generating: FactoryItemInfo:
	set(v):
		generating = v
		_precompute_offsets()
		_cooldown = 0
var _cooldown: int = 0
var _offsets: Dictionary[FactoryBuilding.Rotation, Vector2] = { }


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
	var where_to := Vector2(position + output_port.position + output_port.facing) + _offsets[rotation]
	if not _can_output_to(generating, output_port, where_to):
		return
	grid.place_item(generating, where_to)
	_cooldown = 40


func open_interface() -> void:
	var interface: GeneratorInterface = INTERFACE.instantiate()
	InterfaceCanvasLayer.add_child(interface)
	var _on_item_pressed: Callable = func(item: FactoryItemInfo) -> void:
		generating = item
		interface.change_output(generating)
	interface.item_pressed.connect(_on_item_pressed)
	interface.change_output(generating)


func get_vars() -> Dictionary:
	# NOTE: generating must come before _cooldown here.
	# The generating setter resets _cooldown to 0, so _cooldown
	# must be restored after generating to preserve the saved value.
	return {
		&"generating": generating,
		&"_cooldown": _cooldown,
	}


func _precompute_offsets() -> void:
	if generating == null:
		return
	_offsets[FactoryBuilding.Rotation.NORMAL] = (
			Vector2.DOWN * .5 + Vector2.UP * generating.grid_size.y * .5)
	_offsets[FactoryBuilding.Rotation.CLOCKWISE] = (
			Vector2.RIGHT * .5 + Vector2.LEFT * generating.grid_size.x * .5)
	_offsets[FactoryBuilding.Rotation.COUNTERCLOCKWISE] = (
			Vector2.DOWN + Vector2.UP * generating.grid_size.y +
			Vector2.RIGHT * .5 + Vector2.LEFT * generating.grid_size.x * .5)
	_offsets[FactoryBuilding.Rotation.FLIPPED] = (
			Vector2.RIGHT + Vector2.LEFT * generating.grid_size.x +
			Vector2.DOWN * .5 + Vector2.UP * generating.grid_size.y * .5)
