class_name SpeedProcessorBehavior
extends ProcessorBehavior

@export var speed_mult: float = 2.0

func apply(item: Item) -> void:
	item.stats["speed_mod"] = item.stats.get("speed_mod", 1.0) * speed_mult
