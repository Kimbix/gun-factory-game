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
@export var splitter_type: ComponentType

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
var _coin_icon: Node2D
var _coin_label: Label
var _ammo_label: Label

var edit_mode: bool = false
var cursor_cell: Vector2i = Vector2i.ZERO
var selected_slot: int = 0
var preview_rotation: int = 0

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

	overlay_viewer = GridViewer.new()
	overlay_viewer.position = Vector2(4, 120)
	overlay_viewer.inventory_y = grid_height * Grid.CELL_SIZE + 4
	overlay_viewer.bind(grid)
	var player := get_parent() as Player
	if player != null and player.inventory != null:
		overlay_viewer.inventory = player.inventory
	_add_overlay_to_scene.call_deferred()

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
	_update_coin_label()
	_update_ammo_label()


func _update_coin_label() -> void:
	if _coin_label == null:
		return
	var player := get_parent() as Player
	if player == null:
		return
	_coin_label.text = "%d" % player.coins


func _add_overlay_to_scene() -> void:
	var cl := CanvasLayer.new()
	_coin_icon = Node2D.new()
	_coin_icon.position = Vector2(4, 4)
	var coin_sprite := Sprite2D.new()
	coin_sprite.texture = load("res://assets/world/spr_coin.png")
	_coin_icon.add_child(coin_sprite)
	_coin_label = Label.new()
	_coin_label.position = Vector2(6, -4)
	_coin_label.add_theme_font_size_override(&"font_size", 8)
	_coin_icon.add_child(_coin_label)
	cl.add_child(_coin_icon)
	cl.add_child(overlay_viewer)
	get_tree().current_scene.add_child(cl)
	tree_exiting.connect(func(): cl.queue_free())


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
	if not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_F1:
			overlay_viewer.visible = not overlay_viewer.visible
		KEY_F2:
			edit_mode = not edit_mode
			if not edit_mode:
				overlay_viewer.cursor_cell = Vector2i(-1, -1)
				overlay_viewer.queue_redraw()
			else:
				preview_rotation = 0
				overlay_viewer.cursor_cell = cursor_cell
				overlay_viewer.queue_redraw()
		_:
			if not edit_mode:
				return
			_handle_edit_input(event)


func _handle_edit_input(event: InputEventKey) -> void:
	match event.keycode:
		KEY_UP:
			cursor_cell.y = maxi(cursor_cell.y - 1, 0)
		KEY_DOWN:
			cursor_cell.y = mini(cursor_cell.y + 1, grid_height - 1)
		KEY_LEFT:
			cursor_cell.x = maxi(cursor_cell.x - 1, 0)
		KEY_RIGHT:
			cursor_cell.x = mini(cursor_cell.x + 1, grid_width - 1)
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8:
			selected_slot = event.keycode - KEY_1
		KEY_R:
			preview_rotation = (preview_rotation + 1) % 4
		KEY_ENTER, KEY_KP_ENTER:
			_place_at_cursor()
		KEY_BACKSPACE, KEY_DELETE:
			_remove_at_cursor()
		_:
			return
	overlay_viewer.cursor_cell = cursor_cell
	overlay_viewer.selected_slot = selected_slot
	overlay_viewer.preview_rotation = preview_rotation
	overlay_viewer.queue_redraw()


func _place_at_cursor() -> void:
	var player := get_parent() as Player
	if player == null or player.inventory == null:
		return
	var slot := player.inventory.get_slot(selected_slot)
	if slot == null or slot.is_empty():
		return
	if not grid.is_empty(cursor_cell):
		return
	var comp := Component.new(slot.component_type)
	if not grid.place(comp, cursor_cell, preview_rotation):
		return
	player.inventory.remove_item(slot.component_type, 1)
	overlay_viewer.mark_dirty()


func _remove_at_cursor() -> void:
	var player := get_parent() as Player
	if player == null or player.inventory == null:
		return
	var comp := grid.component_at(cursor_cell)
	if comp == null or comp.type == null:
		return
	if comp.type.fixed:
		return
	grid.remove(comp)
	player.inventory.add_item(comp.type, 1)
	overlay_viewer.mark_dirty()


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
