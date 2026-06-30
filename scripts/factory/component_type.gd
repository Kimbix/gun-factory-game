@tool
class_name ComponentType
extends Resource

## Static definition of a factory component. Authored as a .tres per component kind.
## Holds everything the viewer/sim needs to identify and render the component.

@export var sprite: Texture2D
@export var footprint: Array[Vector2i] = [Vector2i.ZERO]
## Port layout per rotation 0 (East-facing). Each entry: {face: Vector2i, role: "in"|"out"}.
@export var ports: Array[Dictionary] = []
## Seconds per craft (0 for non-processors like conveyors, ports, walls).
@export var craft_time: float = 0.0
## True for chassis-fixed components (walls, input/output ports) — not player-placeable.
@export var fixed: bool = false

## Identifies the component behavior for sim dispatch. Examples:
##   &"conveyor", &"input_port", &"output_port", &"processor", &"wall".
@export var kind: StringName = &""

## For input ports: the material this port emits. For output ports: the recipe material.
## Other components ignore this.
@export var material: StringName = &""