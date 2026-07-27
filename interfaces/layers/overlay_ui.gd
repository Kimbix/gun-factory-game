class_name OverlayUI
extends CanvasLayer

@onready var _level_bar: PlayerLevelBar = $PlayerLevelBar


func setup(level_system: LevelSystem) -> void:
	_level_bar.setup(level_system)
