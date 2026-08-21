class_name DamageRoll extends RefCounted

var damage: int
var crit: bool


func _init(p_damage: int = 0, p_crit: bool = false) -> void:
	damage = p_damage
	crit = p_crit
