class_name Player
extends CharacterBody2D
## Top-down player character. WASD movement.

@export var speed: float = 100.0

var inventory: Inventory = Inventory.new()
var coins: int = 0
var _interact_area: Area2D

const STARTING_ITEMS := {
	"res://assets/components/conveyor.tres": 10,
	"res://assets/components/fast_conveyor.tres": 10,
	"res://assets/components/turbo_conveyor.tres": 10,
	"res://assets/components/damage_processor.tres": 10,
	"res://assets/components/speed_processor.tres": 10,
	"res://assets/components/splitter.tres": 10,
}


func _ready() -> void:
	for path in STARTING_ITEMS:
		var type := load(path) as ComponentType
		if type != null:
			inventory.add_item(type, STARTING_ITEMS[path])

	_interact_area = Area2D.new()
	_interact_area.collision_mask = 8
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 16.0
	_interact_area.add_child(shape)
	add_child(_interact_area)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		var closest: ItemPickup = null
		var closest_dist := INF
		for area in _interact_area.get_overlapping_areas():
			var pickup := area.get_parent() as ItemPickup
			if pickup == null:
				continue
			var dist := global_position.distance_squared_to(pickup.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = pickup
		if closest == null or closest.component_type == null:
			return
		var remaining := inventory.add_item(closest.component_type, 1)
		if remaining == 0:
			var name := String(closest.component_type.kind).capitalize()
			_spawn_pickup_message("+1 " + name)
			closest.queue_free()
		else:
			_spawn_pickup_message("Inventory Full")


func _spawn_pickup_message(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override(&"font_size", 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-40, -28)
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 16, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(label.queue_free)


func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis(&"move_left", &"move_right")
	dir.y = Input.get_axis(&"move_up", &"move_down")
	velocity = dir.normalized() * speed
	move_and_slide()