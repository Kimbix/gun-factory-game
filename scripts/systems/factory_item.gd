class_name FactoryItem
extends RefCounted

var position: Vector2
var rect: Rect2:
	get():
		return Rect2(position, _info.grid_size)
var texture: Texture2D:
	get():
		return _info.texture
var name: String:
	get():
		return _info.name
var shooting_strategy: ShootingStrategy
var _info: FactoryItemInfo


func _init(info: FactoryItemInfo, _position: Vector2) -> void:
	self.position = _position
	_info = info


func get_info() -> FactoryItemInfo:
	return _info
