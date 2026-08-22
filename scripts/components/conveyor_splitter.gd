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

	if _output_item(info, port):
		_items.pop_front()
		_cooldown = COOLDOWN
