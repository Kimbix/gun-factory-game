class_name SpawnPoint
extends Marker2D

@export var enemy: PackedScene
@export var wave_indices: Array[int] = [0]


func _ready() -> void:
	add_to_group("spawn_point")
