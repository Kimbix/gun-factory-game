class_name SaveGridInterface
extends InterfaceWindow

const SAVE_DIR := "user://"
const PIXEL_SCALE := 32

var player_grid: PlayerGrid
var _data: PlayerGridData


func _ready() -> void:
	%FileNameInput.text = "grid_save"
	%FileNameInput.text_submitted.connect(_on_save)
	%SaveButton.pressed.connect(_on_save)
	%CancelButton.pressed.connect(_on_cancel)

	if player_grid == null:
		return
	_data = player_grid.to_data()
	_generate_preview()


func _generate_preview() -> void:
	var img := Image.create(_data.dimensions.x, _data.dimensions.y, false, Image.FORMAT_RGB8)
	for entry: BuildingEntry in _data.buildings:
		img.set_pixel(entry.position.x, entry.position.y, entry.info.color)

	var texture := ImageTexture.create_from_image(img)
	%Preview.texture = texture
	%Preview.custom_minimum_size = Vector2(
		_data.dimensions.x * PIXEL_SCALE,
		_data.dimensions.y * PIXEL_SCALE,
	)


func _on_save(_submitted_text: String = "") -> void:
	var save_as: String = %FileNameInput.text.strip_edges()
	if save_as.is_empty():
		%ErrorLabel.text = "Name cannot be empty"
		return

	var path := SAVE_DIR.path_join(save_as + ".tres")
	var err := ResourceSaver.save(_data, path)
	if err == OK:
		print("Grid saved to %s" % path)
		InterfaceSupervisor.instance.close_interface(
			InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
			self,
		)
	else:
		%ErrorLabel.text = "Failed to save: %d" % err


func _on_cancel() -> void:
	InterfaceSupervisor.instance.close_interface(
		InterfaceSupervisor.InterfaceType.FACTORY_BUILDING, self,
	)
