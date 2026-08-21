class_name DamageNumberPool
extends Node

const POOL_SIZE := 100
const SCENE := preload("uid://cd804e2yjv2fy")

static var _instance: DamageNumberPool

var pool: Array[DamageNumber] = []


static func create() -> DamageNumber:
	var dn: DamageNumber
	if _instance.pool.is_empty():
		dn = SCENE.instantiate()
		_instance.add_child(dn)
		return dn
	dn = _instance.pool.pop_back()
	dn.process_mode = PROCESS_MODE_INHERIT
	dn.visible = true
	return dn


static func show(amount: int, crit: bool, world_pos: Vector2) -> void:
	var dn := create()
	var color := Color.YELLOW if not crit else Color(0.9, 0.15, 0.05)
	var text := str(amount) + ("!" if crit else "")
	dn.play(text, color, world_pos)


static func free_number(node: DamageNumber) -> void:
	if _instance == null:
		node.queue_free()
		return
	node.visible = false
	node.process_mode = PROCESS_MODE_DISABLED
	_instance.pool.append(node)


func _ready() -> void:
	_instance = self
	for i in POOL_SIZE:
		var dn := SCENE.instantiate()
		dn.visible = false
		dn.process_mode = PROCESS_MODE_DISABLED
		add_child(dn)
		pool.append(dn)
