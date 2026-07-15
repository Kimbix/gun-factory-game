class_name LevelSystem
extends Node

signal leveled_up(level: int)
signal gold_changed(amount: int)

var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 5
var gold: int = 0


func add_xp(amount: int) -> void:
	xp += amount
	gold += amount
	gold_changed.emit(gold)
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = xp_required_for_level(level)
		leveled_up.emit(level)


func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


static func xp_required_for_level(lvl: int) -> int:
	if lvl <= 0:
		return 0

	match lvl:
		1:
			return 5
		2, 3, 4, 5:
			return 10
		6, 7, 8, 9, 10:
			return 20
		11, 12, 13, 14, 15, 16, 17, 18, 19, 20:
			return 40

	if lvl <= 40:
		return 80

	return 100 + maxi(0, lvl - 41) * 20
