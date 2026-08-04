@abstract
class_name FactoryComponent
extends RefCounted

var building: FactoryBuilding
var overlay_strategy: OverlayStrategy = null:
	set(v):
		overlay_strategy = v
		var g := grid
		if g == null:
			return
		g.overlay_changed.emit(position)
var rotation: FactoryBuilding.Rotation:
	get():
		return building.rotation
var grid: PlayerGrid:
	get():
		if not is_instance_valid(building):
			return null
		return building.grid if is_instance_valid(building.grid) else null
var position: Vector2i:
	get():
		return building.position
var rect: Rect2:
	get():
		return building.rect


func setup() -> void:
	pass


func tick() -> void:
	pass


func set_var(n: StringName, v: Variant) -> void:
	set(n, v)


func get_vars() -> Dictionary:
	return { }


func can_accept(_item: FactoryItem) -> bool:
	return true


func receive_item(_item: FactoryItem) -> void:
	pass


func open_interface(_interface_supervisor: InterfaceSupervisor) -> void:
	pass


var _progress_interface: RecipeMachineInterface


func _notify_progress(progress: int, total: int) -> void:
	if _progress_interface != null:
		_progress_interface.update_completion(progress, total)


func _on_interface_closed() -> void:
	_progress_interface = null


func _can_output_to(item: FactoryItemInfo, port: Port, at_position: Vector2 = Vector2.INF) -> bool:
	var g := grid
	if g == null:
		return false

	var where: Vector2 = (
			at_position
			if at_position != Vector2.INF
			else Vector2(building.position + port.position + port.facing)
	)
	var target := g.get_building(where.floor())
	if target == null:
		return false
	return target.behaviour.can_accept(FactoryItem.new(item, where))


func _get_available_out_port() -> Port:
	var g := grid
	if g == null:
		return null
	var my_ports := g.get_building_ports(position).filter(Port.output_mode_filter)
	if my_ports.size() == 0:
		return null
	return my_ports.front()


func _notify(what: String, args: Array) -> void:
	var g := grid
	if g == null:
		return
	var to_call: Array = [what]
	to_call.append_array(args)
	g.emit_signal.callv(to_call)


func _can_output() -> bool:
	var g := grid
	if g == null:
		return false

	var my_ports := g.get_building_ports(position).filter(Port.output_mode_filter)
	if my_ports.size() == 0:
		return false

	for p: Port in my_ports:
		var give_block_position := position + p.position
		var receive_block_position := give_block_position + p.facing

		if g.get_building(receive_block_position) == null:
			continue

		var their_ports := (g.get_building_ports(receive_block_position)
				.filter(Port.input_mode_filter))
		for other_p: Port in their_ports:
			var receive_from := receive_block_position + other_p.position + other_p.facing
			if give_block_position == receive_from:
				return true
	return false
