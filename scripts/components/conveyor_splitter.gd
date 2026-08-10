class_name ConveyorSplitter
extends FactoryComponent

const MAX_STORED := 3
const COOLDOWN := 10

var _items: Array[FactoryItemInfo] = []
var _next_out_port: int = 0
var _cooldown: int = 0


func can_accept(_item: FactoryItem) -> bool:
	return _items.size() < MAX_STORED


func receive_item(item: FactoryItem) -> void:
	_items.append(item.get_info())
	var g := grid
	if g == null:
		return
	g.destroy_item(item)


func tick() -> void:
	if _cooldown > 0:
		_cooldown -= 1
		return

	if _items.is_empty():
		return

	var g := grid
	if g == null:
		return

	var ports := g.get_building_ports(position).filter(Port.output_mode_filter)
	if ports.is_empty():
		return

	var port: Port = ports[_next_out_port]
	_next_out_port = (_next_out_port + 1) % ports.size()

	var info := _items[0]
	var gs := info.grid_size
	var facing := port.facing

	var offset := Vector2.ZERO
	if facing.x != 0:
		offset.x = 0.0 if facing.x > 0 else 1.0 - gs.x
		offset.y = 0.5 - gs.y * 0.5
	else:
		offset.x = 0.5 - gs.x * 0.5
		offset.y = 0.0 if facing.y > 0 else 1.0 - gs.y

	if _output_item(info, port, offset):
		_items.pop_front()
		_cooldown = COOLDOWN
