class_name TextOverlayStrategy
extends OverlayStrategy

var text: String


func get_layers() -> Array[Dictionary]:
	if text.is_empty():
		return []
	return [{ "text": text }]
