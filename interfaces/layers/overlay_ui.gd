class_name OverlayUI
extends CanvasLayer

@onready var _level_bar: PlayerLevelBar = $PlayerLevelBar
@onready var _health_bar = $PlayerHealthBar


func setup(player: SimpleCharacter) -> void:
	_level_bar.setup(player.level_system)
	_health_bar.setup(player)
