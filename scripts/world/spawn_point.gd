class_name SpawnPoint
extends Marker2D

const WaveSpawnScript := preload("res://scripts/world/wave_spawn.gd")

@export var spawns: Array[Resource] = []


func _ready() -> void:
	add_to_group("spawn_point")


func get_spawns_for_wave(wave: int) -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	for s in spawns:
		if s.script != WaveSpawnScript:
			continue
		var wi: Variant = s.get("wave_index")
		var enemy: Variant = s.get("enemy")
		if wi != null and wi == wave and enemy != null:
			result.append(enemy as PackedScene)
	return result

