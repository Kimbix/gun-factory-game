class_name DamageProcessorBehavior
extends ProcessorBehavior

@export var damage_add: float = 1.0

func apply(item: Item) -> void:
	item.stats["damage_bonus"] = item.stats.get("damage_bonus", 0.0) + damage_add
