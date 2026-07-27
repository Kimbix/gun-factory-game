class_name OverlayUI
extends CanvasLayer

@onready var _level_bar: PlayerLevelBar = $PlayerLevelBar
@onready var _health_bar = $PlayerHealthBar
@onready var _timer: GameTimer = $GameTimer


func setup(player: SimpleCharacter, game_director: GameDirector) -> void:
	_level_bar.setup(player.level_system)
	_health_bar.setup(player)
	_timer.setup(game_director)
