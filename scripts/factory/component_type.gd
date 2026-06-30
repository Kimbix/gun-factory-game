@tool
class_name ComponentType
extends Resource
## Static definition of a factory component. Authored as a .tres per component kind.
## Holds everything the viewer/sim needs to identify and render the component.

@export var sprite: Texture2D
@export var footprint: Array[Vector2i] = [Vector2i.ZERO]
## Port layout per rotation 0 (East-facing). Each entry: {face: Vector2i, role: "in"|"out"}.
@export var ports: Array[Dictionary] = []
## True for chassis-fixed components (walls, input/output ports) — not player-placeable.
@export var fixed: bool = false

## Strategy object driving this component's tick behavior. Authored as a .tres
## referencing a ComponentBehavior subclass.
@export var behavior: ComponentBehavior

## Identifies the component behavior for sim dispatch. Examples:
##   &"conveyor", &"input_port", &"output_port", &"processor", &"wall".
@export var kind: StringName = &""

## For input ports: the material this port emits. For output ports: the recipe material.
## Other components ignore this.
@export var material: StringName = &""

## Which render layer this component's sprite belongs to. The viewer draws layers in
## ascending order (background -> items -> overlays). Items layer is implicit (every
## component can hold an item); this field only controls where the *sprite* draws.
enum RenderLayer { BACKGROUND, OVERLAY }
@export var render_layer: RenderLayer = RenderLayer.BACKGROUND
