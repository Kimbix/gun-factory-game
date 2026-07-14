class_name ItemOverlayStrategy
extends OverlayStrategy

const SHADOW := preload("res://assets/effects/spr_shadow.png")

var item_info: FactoryItemInfo


func get_layers() -> Array[Dictionary]:
	var layers: Array[Dictionary] = []
	layers.append({ "texture": SHADOW })
	if item_info != null and item_info.texture != null:
		layers.append({ "texture": item_info.texture })
	return layers
