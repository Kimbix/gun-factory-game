@abstract
class_name FactoryComponent
extends RefCounted

var building: FactoryBuilding
var overlay_strategy: OverlayStrategy = null
var rotation: FactoryBuilding.Rotation:
	get():
		return building.rotation
var grid: PlayerGrid:
	get():
		return building.grid
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


func open_interface() -> void:
	pass


func _can_output_to(item: FactoryItemInfo, port: Port, at_position: Vector2 = Vector2.INF) -> bool:
	var where: Vector2 = at_position if at_position != Vector2.INF else Vector2(building.position + port.position + port.facing)
	var target := grid.get_building(where.floor())
	if target == null:
		return false
	return target.behaviour.can_accept(FactoryItem.new(item, where))


func _get_available_out_port() -> Port:
	var my_ports := grid.get_building_ports(position).filter(Port.output_mode_filter)
	if my_ports.size() == 0:
		return null
	return my_ports.front()


func _notify(what: String, args: Array) -> void:
	var to_call: Array = [what]
	to_call.append_array(args)
	grid.emit_signal.callv(to_call)


func _can_output() -> bool:
	var my_ports := grid.get_building_ports(position).filter(Port.output_mode_filter)
	if my_ports.size() == 0:
		return false

	for p: Port in my_ports:
		# Get the position of the block that contains the port
		var give_block_position := position + p.position
		# Check the position we're looking at for ports
		var receive_block_position := give_block_position + p.facing

		if grid.get_building(receive_block_position) == null:
			continue

		var their_ports := (grid.get_building_ports(receive_block_position)
				.filter(Port.input_mode_filter))
		for other_p: Port in their_ports:
			# Get the block this port receives from by summing the position of
			# the port within the building + the direction it's facing
			var receive_from := receive_block_position + other_p.position + other_p.facing
			# If they match, the port can output
			if give_block_position == receive_from:
				# TODO: Each building has it's own way of determining
				# if they can receive an item other than having ports
				return true
	return false
