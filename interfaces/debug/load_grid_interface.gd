class_name LoadGridInterface
extends InterfaceWindow

signal grid_loaded

const SAVE_DIR := "user://"

var player_grid: PlayerGrid
var interface_supervisor: InterfaceSupervisor


func _ready() -> void:
	%CancelButton.pressed.connect(_on_cancel)
	_populate_list()


func _populate_list() -> void:
	var list := %ItemList
	for child in list.get_children():
		child.queue_free()

	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		breakpoint
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if file_name.ends_with(".tres"):
			var path := SAVE_DIR.path_join(file_name)
			print("Loading %s " % path)
			_add_grid_entry(list, path, file_name.trim_suffix(".tres"))
		file_name = dir.get_next()


func _add_grid_entry(list: VBoxContainer, path: String, display_name: String) -> void:
	var data := ResourceLoader.load(path) as PlayerGridData
	if data == null:
		breakpoint
		return

	var entry := VBoxContainer.new()
	entry.name = display_name
	entry.alignment = BoxContainer.ALIGNMENT_CENTER

	var btn := Button.new()
	btn.name = "%s_btn" % display_name
	var preview_size := Vector2(data.dimensions.x * 2, data.dimensions.y * 2)
	btn.custom_minimum_size = Vector2(maxf(preview_size.x, 64), maxf(preview_size.y, 64))
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	if data.preview != null:
		var texture := ImageTexture.create_from_image(data.preview)
		btn.icon = texture
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	btn.pressed.connect(_on_grid_selected.bind(path))
	entry.add_child(btn)

	var label := Label.new()
	label.name = "%s_lbl" % display_name
	label.text = display_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	entry.add_child(label)

	list.add_child(entry)


func _on_grid_selected(path: String) -> void:
	if player_grid == null:
		return
	var data := ResourceLoader.load(path) as PlayerGridData
	if data == null:
		return
	player_grid.from_data(data)
	grid_loaded.emit()
	if interface_supervisor != null:
		interface_supervisor.close_interface(
			InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
			self,
		)


func _on_cancel() -> void:
	if interface_supervisor != null:
		interface_supervisor.close_interface(
			InterfaceSupervisor.InterfaceType.FACTORY_BUILDING,
			self,
		)
