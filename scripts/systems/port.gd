class_name Port
extends Resource

enum PortMode {
	IN,
	OUT,
}

@export var position: Vector2i
@export var facing: Vector2i
@export var mode: PortMode


static func output_mode_filter(p: Port) -> bool:
	return p.mode == Port.PortMode.OUT


static func input_mode_filter(p: Port) -> bool:
	return p.mode == Port.PortMode.IN
