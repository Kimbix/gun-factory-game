class_name GameOverMenu
extends InterfaceWindow

var is_win: bool
var grid_preview: Image
var match_stats: MatchStats

@export var return_button: Button
@onready var _title_label: Label = $ColorRect/MainHBox/LeftVBox/TitleLabel
@onready var _preview_texture: TextureRect = $ColorRect/MainHBox/RightVBox/GridPreview
@onready var _stats_container: VBoxContainer = (
		$ColorRect/MainHBox/LeftVBox/ScrollContainer/StatsContainer
)


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)
	if is_win:
		_title_label.text = "Victory!"
	_set_grid_preview()
	if match_stats != null:
		_build_stats_ui()


func _set_grid_preview() -> void:
	if grid_preview == null:
		_preview_texture.hide()
		return
	var cell_size := 32
	var preview_size := Vector2i(
		grid_preview.get_width() * cell_size,
		grid_preview.get_height() * cell_size,
	)
	grid_preview.resize(preview_size.x, preview_size.y, Image.INTERPOLATE_NEAREST)
	var texture := ImageTexture.create_from_image(grid_preview)
	_preview_texture.texture = texture


func _format_number(value: float) -> String:
	if value == int(value):
		return "%s" % int(value)
	return "%s" % value


func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%02d:%02d" % [mins, secs]


func _add_header(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_stats_container.add_child(label)


func _add_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	_stats_container.add_child(grid)
	return grid


func _add_row(grid: GridContainer, key: String, value: String) -> void:
	var key_label := Label.new()
	key_label.text = key
	var val_label := Label.new()
	val_label.text = value
	val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grid.add_child(key_label)
	grid.add_child(val_label)


func _add_dict_rows(grid: GridContainer, dict: Dictionary) -> void:
	var keys: Array = dict.keys()
	keys.sort()
	for k: Variant in keys:
		_add_row(grid, "  %s" % k, _format_number(dict[k]))


func _add_separator() -> void:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 4)
	_stats_container.add_child(sep)


func _build_stats_ui() -> void:
	_add_header("Combat")
	var combat_grid := _add_grid()
	_add_row(combat_grid, "Total Damage Dealt", _format_number(match_stats.total_damage_dealt))
	if not match_stats.damage_by_ammo_type.is_empty():
		_add_row(combat_grid, "By Ammo Type", "")
		_add_dict_rows(combat_grid, match_stats.damage_by_ammo_type)
	if not match_stats.damage_by_enemy_type.is_empty():
		_add_row(combat_grid, "By Enemy Type", "")
		_add_dict_rows(combat_grid, match_stats.damage_by_enemy_type)
	_add_row(combat_grid, "Critical Hits", _format_number(match_stats.critical_hits_landed))
	if match_stats.critical_damage_dealt > 0:
		_add_row(
			combat_grid,
			"Crit Damage Dealt",
			_format_number(match_stats.critical_damage_dealt),
		)
	_add_row(combat_grid, "Total Damage Taken", _format_number(match_stats.total_damage_taken))
	if not match_stats.damage_taken_by_enemy_type.is_empty():
		_add_row(combat_grid, "By Enemy Type", "")
		_add_dict_rows(combat_grid, match_stats.damage_taken_by_enemy_type)
	_add_row(combat_grid, "Total Healing Done", _format_number(match_stats.total_healing_done))
	if not match_stats.healing_by_source.is_empty():
		_add_row(combat_grid, "By Source", "")
		_add_dict_rows(combat_grid, match_stats.healing_by_source)
	_add_row(combat_grid, "Total Enemies Killed", _format_number(match_stats.total_enemies_killed))
	if not match_stats.enemies_killed_by_type.is_empty():
		_add_row(combat_grid, "By Type", "")
		_add_dict_rows(combat_grid, match_stats.enemies_killed_by_type)

	_add_separator()
	_add_header("Economy")
	var econ_grid := _add_grid()
	var xp_text := _format_number(match_stats.xp_earned_total)
	if match_stats.xp_earned_base != match_stats.xp_earned_total:
		xp_text += " (base: %s)" % _format_number(match_stats.xp_earned_base)
	_add_row(econ_grid, "XP Earned", xp_text)
	var gold_text := _format_number(match_stats.gold_earned_total)
	if match_stats.gold_earned_base != match_stats.gold_earned_total:
		gold_text += " (base: %s)" % _format_number(match_stats.gold_earned_base)
	_add_row(econ_grid, "Gold Earned", gold_text)

	_add_separator()
	_add_header("Player Stats")
	var stats_grid := _add_grid()
	_add_row(stats_grid, "Level", _format_number(match_stats.final_level))
	_add_row(stats_grid, "Max HP", _format_number(match_stats.max_health))
	_add_row(stats_grid, "Move Speed", _format_number(match_stats.move_speed))
	_add_row(stats_grid, "Armor", _format_number(match_stats.armor))
	_add_row(stats_grid, "Crit Chance", "%.0f%%" % (match_stats.crit_chance * 100.0))
	_add_row(stats_grid, "Crit Damage", "+%.0f%%" % (match_stats.crit_damage * 100.0))
	_add_row(stats_grid, "Health Regen", _format_number(match_stats.health_regen))
	_add_row(stats_grid, "Tick Speed", _format_number(match_stats.tick_speed))
	_add_row(stats_grid, "Pickup Range", _format_number(match_stats.pickup_range))
	_add_row(stats_grid, "Luck", _format_number(match_stats.luck))
	_add_row(stats_grid, "XP Gain", "%.0f%%" % (match_stats.xp_gain * 100.0))
	_add_row(stats_grid, "Gold Gain", "%.0f%%" % (match_stats.gold_gain * 100.0))
	_add_row(stats_grid, "Difficulty", _format_number(match_stats.difficulty))

	_add_separator()
	_add_header("Match")
	var match_grid := _add_grid()
	_add_row(match_grid, "Time Survived", _format_time(match_stats.time_survived))
	_add_row(match_grid, "Waves Completed", _format_number(match_stats.waves_completed))
	_add_row(match_grid, "Difficulty Multiplier", "%.1fx" % match_stats.difficulty_multiplier)


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(&"uid://c0f8gqiflva8v")
