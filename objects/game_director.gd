class_name GameDirector
extends WorldEnvironment

@export var player_character_scene: PackedScene
@export var enemy_waves: EnemyWaves
@export var enemy_cap := 50
@export_category("Spawn Specifications")
@export var spawn_interval := 10.0
@export var spawn_per_wave_percent := .05
@export var spawn_distance_min := 250.0
@export var spawn_distance_max := 400.0

var elapsed_time: float
var enemies: Array[BaseEnemy] = []
var active_wave: EnemyWave
var wave_index: int
var player_instance: SimpleCharacter


func _ready() -> void:
	_spawn_player()
	elapsed_time = 0.0
	wave_index = 0
	active_wave = enemy_waves.get_first()

	var timer := Timer.new()
	timer.timeout.connect(_spawn_enemies)
	timer.wait_time = spawn_interval
	timer.autostart = true
	add_child(timer)
	_spawn_enemies()


func _process(delta: float) -> void:
	elapsed_time += delta
	if active_wave != null and elapsed_time >= active_wave.end_time_minutes * 60.0:
		wave_index += 1
		active_wave = enemy_waves.get_wave(wave_index)


func _spawn_player(spawn_pos: Vector2 = Vector2.ZERO) -> void:
	player_instance = player_character_scene.instantiate()
	player_instance.position = spawn_pos
	add_child(player_instance)


func _spawn_enemies() -> void:
	if active_wave == null or enemies.size() >= enemy_cap:
		return

	var missing: int = enemy_cap - enemies.size()
	var to_spawn := ceili(missing * spawn_per_wave_percent)
	for i: Variant in to_spawn:
		if enemies.size() >= enemy_cap:
			return

		var info: EnemyInfo = active_wave.enemies.pick_random()
		var instance: BaseEnemy = info.scene.instantiate()
		instance.player = player_instance
		instance.position = (
				player_instance.position
				+ ((Vector2.RIGHT * randf_range(spawn_distance_min, spawn_distance_max))
						.rotated(randf() * TAU))
		)
		add_child(instance)
		enemies.append(instance)
		instance.tree_exited.connect(_on_enemy_killed.bind(instance))


func _on_enemy_killed(which: BaseEnemy) -> void:
	enemies.erase(which)
