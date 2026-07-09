class_name EnemyWaves
extends Resource

@export var waves: Array[EnemyWave]


func get_first() -> EnemyWave:
	return get_wave(0)


func get_wave(i: int) -> EnemyWave:
	return waves[i] if i < waves.size() else null
