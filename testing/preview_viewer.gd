extends Control

const SAVE_PATH := "user://grid_save.tres"
const PIXEL_SCALE := 32

@onready var texture_rect: TextureRect = %TextureRect


func _ready() -> void:
	_load_preview()


func _load_preview() -> void:
	if not ResourceLoader.exists(SAVE_PATH):
		print("No save file found at %s" % SAVE_PATH)
		return

	var data := ResourceLoader.load(SAVE_PATH) as PlayerGridData
	if data == null:
		print("Failed to load save file")
		return

	var img := Image.create(data.dimensions.x, data.dimensions.y, false, Image.FORMAT_RGB8)
	for x in data.dimensions.x:
		for y in data.dimensions.y:
			var v := Vector2i(x, y)
			img.set_pixel(x, y, Color.BLACK)

	for entry: BuildingEntry in data.buildings:
		img.set_pixel(entry.position.x, entry.position.y, entry.info.color)

	var texture := ImageTexture.create_from_image(img)
	texture_rect.texture = texture
	texture_rect.position = Vector2(
		(size.x - data.dimensions.x * PIXEL_SCALE) * .5,
		(size.y - data.dimensions.y * PIXEL_SCALE) * .5,
	)
	texture_rect.size = Vector2(data.dimensions.x * PIXEL_SCALE, data.dimensions.y * PIXEL_SCALE)
	print("Preview generated from %s" % SAVE_PATH)
