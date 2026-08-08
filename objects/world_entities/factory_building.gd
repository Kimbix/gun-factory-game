class_name FactoryWorkshop
extends Area2D

## Emitted when the player enters the proximity area.
signal player_near_changed(is_near: bool)

## Emitted when the cooldown finishes.
signal cooldown_finished

## Radius of the proximity area in pixels.
@export var proximity_radius := 200.0

## Text shown on the hint prompt when the building is usable.
@export var prompt_text := "Press F to build"

## Seconds the building is unusable after the player uses it and exits the area.
@export var cooldown_duration := 90.0

## Whether the player is currently inside the proximity area.
var is_player_near := false

## Whether the building is on cooldown after a use.
var is_on_cooldown := false

var _was_used := false

@onready var _proximity_shape: CollisionShape2D = $ProximityArea
@onready var _prompt_label: Label = $Prompt
@onready var _cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	var circle := _proximity_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = proximity_radius
	_prompt_label.visible = false
	_prompt_label.text = prompt_text
	_cooldown_timer.wait_time = cooldown_duration
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func can_be_used() -> bool:
	return is_player_near and not is_on_cooldown


## Called by [GameSupervisor] when the workshop interface opens.
func mark_used() -> void:
	_was_used = true


func _process(_delta: float) -> void:
	if not is_player_near:
		return
	if is_on_cooldown:
		var remaining := ceili(_cooldown_timer.time_left)
		_prompt_label.text = "Cooldown: %d s" % remaining
		_prompt_label.visible = true
	else:
		_prompt_label.text = prompt_text
		_prompt_label.visible = true


func _on_body_entered(body: Node2D) -> void:
	if body is SimpleCharacter:
		is_player_near = true
		player_near_changed.emit(true)


func _on_body_exited(body: Node2D) -> void:
	if body is SimpleCharacter:
		is_player_near = false
		player_near_changed.emit(false)
		_prompt_label.visible = false
		if _was_used and not is_on_cooldown:
			is_on_cooldown = true
			_cooldown_timer.start()
		_was_used = false


func _on_cooldown_timeout() -> void:
	is_on_cooldown = false
	cooldown_finished.emit()
