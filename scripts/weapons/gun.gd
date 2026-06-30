class_name Gun
extends Node2D
## A gun with an internal factory grid. Owns the grid and ticks it continuously.
##
## Ammunition model:
##   input_chamber  — the magazine bucket the factory consumes from. Holds up to
##                    `magazine_size` items. Refilled after reload.
##   chamber        — the output chamber, holds up to `chamber_capacity` items
##                    (fired-ready, one at a time for this gun).
##   max_alive_items — caps items in transit (grid + output chamber combined).
##
## Reload triggers when: input_chamber empty AND output chamber empty AND grid empty.
## Player must click to initiate reload (per spec: "click on empty gun starts reload").
## After `reload_time`, input_chamber refills to `magazine_size`.

@export_group("Grid")
@export var grid_width: int = 5
@export var grid_height: int = 3
@export var tick_interval: float = 0.3
@export var input_port_type: ComponentType
@export var output_port_type: ComponentType
@export var conveyor_type: ComponentType
@export var damage_processor_type: ComponentType
@export var speed_processor_type: ComponentType

@export_group("Chassis")
@export var sprite_texture: Texture2D
@export var max_alive_items: int = 1
@export var chamber_capacity: int = 1
@export var magazine_size: int = 6
@export var reload_time: float = 2.0
@export var fire_stagger: float = 0.05
@export var projectile_speed: float = 200.0
@export var projectile_lifetime: float = 2.0

## Reload state.
enum ReloadState { IDLE, DELAY, REFILL_DONE }
var _reload_state: ReloadState = ReloadState.IDLE
var _reload_timer: float = 0.0

## The magazine bucket the factory consumes from.
var input_chamber: Array[Item] = []
## Output chamber (fired-ready rounds). Each entry is an Item that exited an output port.
var chamber: Array[Item] = []

var grid: Grid
var overlay_viewer: GridViewer
var _ammo_label: Label

var _timer: float = 0.0
var _fire_queue: Array[Item] = []
var _fire_timer: float = 0.0


func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = sprite_texture
	sprite.position = Vector2(8, 0)
	add_child(sprite)

	grid = Grid.new()
	grid.build_rect(grid_width, grid_height)
	var mid_y: int = int(grid_height / 2.0)
	grid.place(Component.new(input_port_type), Vector2i(0, mid_y), 0)
	grid.place(Component.new(output_port_type), Vector2i(grid_width - 1, mid_y), 0)
	grid.place(Component.new(damage_processor_type), Vector2i(1, mid_y), 0)
	grid.place(Component.new(damage_processor_type), Vector2i(2, mid_y), 0)
	grid.place(Component.new(damage_processor_type), Vector2i(3, mid_y), 0)

	overlay_viewer = GridViewer.new()
	overlay_viewer.position = Vector2(10, 10)
	add_child(overlay_viewer)
	overlay_viewer.bind(grid)

	_ammo_label = Label.new()
	_ammo_label.position = Vector2(-16, -18)
	_ammo_label.add_theme_font_size_override(&"font_size", 8)
	add_child(_ammo_label)

	_fill_input_chamber()
	_update_ammo_label()


func _process(delta: float) -> void:
	_timer += delta
	if tick_interval > 0.0:
		while _timer >= tick_interval:
			_timer -= tick_interval
			_inject_from_input_chamber()
			_drain_output_ports()
			grid.tick()
		overlay_viewer.update_interp(clampf(_timer / tick_interval, 0.0, 1.0))
	if _reload_state == ReloadState.DELAY:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_fill_input_chamber()
			_reload_state = ReloadState.IDLE
			print("reloaded")
	if not _fire_queue.is_empty():
		_fire_timer -= delta
		if _fire_timer <= 0.0 and not _fire_queue.is_empty():
			_on_fire(_fire_queue.pop_front())
			_fire_timer = fire_stagger
	_update_ammo_label()


func _fill_input_chamber() -> void:
	input_chamber.clear()
	var base_stats := {
		damage = 1.0,
		speed_mod = 1.0,
		effects = {},
	}
	for i in magazine_size:
		input_chamber.append(Item.new(input_port_type.material, base_stats))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"fire"):
		try_fire()
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		overlay_viewer.visible = not overlay_viewer.visible


## Pre-tick: pull one item from input_chamber into the input port's facing neighbor,
## if the neighbor is empty. Respects max_alive_items (grid + output chamber).
## This bypasses InputPortBehavior; sets grid.emit_quota = 0 to silence it.
func _inject_from_input_chamber() -> void:
	grid.emit_quota = 0
	if _reload_state == ReloadState.DELAY:
		return
	if input_chamber.is_empty():
		return
	var alive := chamber.size()
	for comp in grid.all_components():
		if comp.item != null:
			alive += 1
	if alive >= max_alive_items:
		return
	for comp in grid.all_components():
		if comp.type == null or comp.type.behavior == null:
			continue
		if not (comp.type.behavior is InputPortBehavior):
			continue
		for port in comp.rotated_ports():
			if port.role != &"out":
				continue
			var next_cell: Vector2i = comp.origin + port.face
			var next_comp: Component = grid.component_at(next_cell)
			if next_comp != null and next_comp.item == null:
				var item: Item = input_chamber.pop_front()
				item.from_cell = comp.origin
				next_comp.item = item
				return


## Pull items out of output ports into the chamber, up to `chamber_capacity`.
func _drain_output_ports() -> void:
	for comp in grid.all_components():
		if comp.type == null or comp.type.behavior == null:
			continue
		if not (comp.type.behavior is OutputPortBehavior):
			continue
		if comp.item == null:
			continue
		if chamber.size() >= chamber_capacity:
			continue
		chamber.append(comp.item)
		comp.item = null


## Trigger pull: queue all rounds in the chamber for firing. They exit staggered by
## `fire_stagger` seconds. Reload starts when the gun is fully empty (input chamber
## empty, output chamber empty, grid empty).
func try_fire() -> bool:
	if _reload_state == ReloadState.DELAY:
		print("reloading...")
		return false
	if chamber.is_empty() and _fire_queue.is_empty():
		if _gun_is_empty():
			print("click — gun empty, starting reload")
			_reload_state = ReloadState.DELAY
			_reload_timer = reload_time
			return false
		print("click — chamber empty, factory still working")
		return false
	while not chamber.is_empty():
		_fire_queue.append(chamber.pop_front())
	return true


func _gun_is_empty() -> bool:
	if not input_chamber.is_empty():
		return false
	if not chamber.is_empty():
		return false
	for comp in grid.all_components():
		if comp.item != null:
			return false
	return true


func _on_fire(item: Item) -> void:
	var dir := get_global_mouse_position() - global_position
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	var proj := Projectile.new()
	proj.setup(dir.normalized(), item.stats, projectile_speed, projectile_lifetime)
	var world := get_tree().current_scene
	world.add_child(proj)
	proj.global_position = global_position


func _update_ammo_label() -> void:
	if _ammo_label == null:
		return
	if _reload_state == ReloadState.DELAY:
		_ammo_label.text = "reloading..."
		return
	var remaining := input_chamber.size() + chamber.size()
	for comp in grid.all_components():
		if comp.item != null:
			remaining += 1
	_ammo_label.text = "%d/%d" % [remaining, magazine_size]
