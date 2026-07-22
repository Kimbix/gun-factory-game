class_name EnemyEvents
extends Resource

@export var events: Array[EnemyEvent]

var _fired: Array[bool]


func setup() -> void:
	_fired = []
	_fired.resize(events.size())


func get_next_unfired(time: float) -> EnemyEvent:
	for i in events.size():
		if _fired[i]:
			continue
		if time >= events[i].trigger_time_minutes * 60.0:
			_fired[i] = true
			return events[i]
	return null
