class_name GameSupervisor
extends Node

enum GameState {
	GAMEPLAY,
	BUILDING,
	LEVEL_UP,
	PAUSED,
	GAME_OVER,
}

var match_stats: MatchStats
var _state: GameState = GameState.GAMEPLAY
var _state_before_pause: GameState = GameState.GAMEPLAY
var _state_before_level_up: GameState = GameState.GAMEPLAY
var _active_player: SimpleCharacter
var _interface_supervisor: InterfaceSupervisor
var _pause_menu_instance: PauseMenu
var _game_over_menu_instance: GameOverMenu

@onready var _building_ui: BuildingUI = $InterfaceSupervisor/BuildingUI
@onready var _grid_builder: GridBuilder = (
		$InterfaceSupervisor/BuildingUI/PlayerGridViewer/GridBuilder
)
@onready var _grid_interactor: GridInteractor = (
		$InterfaceSupervisor/BuildingUI/PlayerGridViewer/GridInteractor
)
@onready var _overlay_ui: OverlayUI = $InterfaceSupervisor/OverlayUI


func _ready() -> void:
	match_stats = MatchStats.new()
	match_stats.reset()
	_active_player = %GameplayScene.player_instance
	_interface_supervisor = $InterfaceSupervisor

	_building_ui.player_grid = _active_player.player_grid
	_building_ui.building_inventory = _active_player.building_inventory
	_building_ui.grid_builder = _grid_builder

	_grid_builder.building_inventory = _active_player.building_inventory
	_grid_builder.building_ui = _building_ui

	_grid_interactor.builder = _grid_builder
	_grid_interactor.interface_supervisor = _interface_supervisor

	_interface_supervisor.building_inventory = _active_player.building_inventory
	_interface_supervisor.pause_requested.connect(pause_for_level_up)
	_interface_supervisor.unpause_requested.connect(unpause_from_level_up)
	_active_player.leveled_up.connect(_interface_supervisor.on_leveled_up)
	_active_player.died.connect(_on_player_died)
	SignalBus.damage_dealt.connect(_on_damage_dealt)
	SignalBus.damage_taken.connect(_on_damage_taken)
	SignalBus.healed.connect(_on_healed)
	SignalBus.enemy_killed.connect(_on_enemy_killed)
	SignalBus.xp_changed.connect(_on_xp_changed)
	SignalBus.gold_changed.connect(_on_gold_changed)
	SignalBus.crystal_collected.connect(_on_crystal_collected)

	_overlay_ui.setup(_active_player, %GameplayScene)

	if not InputMap.has_action("pause"):
		var event := InputEventKey.new()
		event.keycode = KEY_P
		InputMap.add_action("pause")
		InputMap.action_add_event("pause", event)

	if not InputMap.has_action("factory_building"):
		var event := InputEventKey.new()
		event.keycode = KEY_F
		InputMap.add_action("factory_building")
		InputMap.action_add_event("factory_building", event)

	if not InputMap.has_action("building_overlay"):
		var event := InputEventKey.new()
		event.keycode = KEY_ALT
		InputMap.add_action("building_overlay")
		InputMap.action_add_event("building_overlay", event)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F4 and event.pressed and not event.echo:
		var director := %GameplayScene as GameDirector
		if director != null and not director.win_triggered:
			director.elapsed_time = director.WIN_TIME - 1.0

	if event.is_action_pressed("pause"):
		if _state not in [GameState.GAMEPLAY, GameState.BUILDING, GameState.PAUSED]:
			return
		match _state:
			GameState.GAMEPLAY, GameState.BUILDING:
				_state_before_pause = _state
				_set_state(GameState.PAUSED)
			GameState.PAUSED:
				_set_state(_state_before_pause)
		return

	if event.is_action_pressed("factory_building"):
		if _state not in [GameState.GAMEPLAY, GameState.BUILDING]:
			return
		match _state:
			GameState.GAMEPLAY:
				_set_state(GameState.BUILDING)
			GameState.BUILDING:
				_set_state(GameState.GAMEPLAY)
		return

	if event.is_action_pressed("building_overlay"):
		if _state != GameState.BUILDING:
			return
		var viewer := _building_ui.player_grid_viewer
		viewer.building_overlay = not viewer.building_overlay
		viewer.queue_redraw()


func get_player() -> SimpleCharacter:
	return _active_player


func pause_for_level_up() -> void:
	_state_before_level_up = _state
	_set_state(GameState.LEVEL_UP)


func unpause_from_level_up() -> void:
	_set_state(_state_before_level_up)


func unpause() -> void:
	if _state == GameState.PAUSED:
		_set_state(_state_before_pause)


func _show_pause_menu() -> void:
	_pause_menu_instance = preload("res://interfaces/menus/pause_menu.tscn").instantiate()
	_interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_pause_menu_instance,
	)


func _hide_pause_menu() -> void:
	if not is_instance_valid(_pause_menu_instance):
		return
	_interface_supervisor.close_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_pause_menu_instance,
	)
	_pause_menu_instance = null


func _show_game_over_menu(is_win: bool = false) -> void:
	if is_instance_valid(_game_over_menu_instance):
		return
	_game_over_menu_instance = preload("res://interfaces/menus/game_over_menu.tscn").instantiate()
	_game_over_menu_instance.is_win = is_win
	_game_over_menu_instance.match_stats = match_stats
	if is_instance_valid(_active_player) and _active_player.player_grid != null:
		_game_over_menu_instance.grid_preview = (
				_active_player.player_grid.to_data().preview
		)
	_interface_supervisor.open_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_game_over_menu_instance,
	)


func _hide_game_over_menu() -> void:
	if not is_instance_valid(_game_over_menu_instance):
		return
	_interface_supervisor.close_interface(
		InterfaceSupervisor.InterfaceType.EMERGENT,
		_game_over_menu_instance,
	)
	_game_over_menu_instance = null


func _on_damage_dealt(
		damage: int,
		ammo_type: StringName,
		enemy_type: StringName,
		was_crit: bool,
) -> void:
	match_stats.total_damage_dealt += damage
	var ammo_key := String(ammo_type)
	match_stats.damage_by_ammo_type[ammo_key] = (
			match_stats.damage_by_ammo_type.get(ammo_key, 0.0) + damage
	)
	var enemy_key := String(enemy_type)
	match_stats.damage_by_enemy_type[enemy_key] = (
			match_stats.damage_by_enemy_type.get(enemy_key, 0.0) + damage
	)
	if was_crit:
		match_stats.critical_hits_landed += 1
		match_stats.critical_damage_dealt += damage


func _on_damage_taken(amount: int, enemy_type: StringName) -> void:
	match_stats.total_damage_taken += amount
	var key := String(enemy_type)
	match_stats.damage_taken_by_enemy_type[key] = (
			match_stats.damage_taken_by_enemy_type.get(key, 0.0) + amount
	)


func _on_healed(amount: int, source: StringName) -> void:
	match_stats.total_healing_done += amount
	var key := String(source)
	match_stats.healing_by_source[key] = (
			match_stats.healing_by_source.get(key, 0.0) + amount
	)


func _on_enemy_killed(enemy_type: StringName) -> void:
	match_stats.total_enemies_killed += 1
	var key := String(enemy_type)
	match_stats.enemies_killed_by_type[key] = (
			match_stats.enemies_killed_by_type.get(key, 0) + 1
	)


func _on_xp_changed(xp: int, _limit: int) -> void:
	match_stats.xp_earned_total = xp


func _on_gold_changed(amount: int) -> void:
	match_stats.gold_earned_total = amount


func _on_crystal_collected(xp_value: int) -> void:
	match_stats.xp_earned_base += xp_value
	match_stats.gold_earned_base += xp_value


func _on_player_died() -> void:
	var director := %GameplayScene as GameDirector
	var is_win := false
	if director != null:
		is_win = director.win_triggered
		match_stats.time_survived = director.elapsed_time
		match_stats.waves_completed = director.wave_index
	match_stats.difficulty_multiplier = (
			_active_player.player_stats.stats[&"difficulty"].value
	)
	match_stats.final_level = _active_player.level_system.level
	for stat_name: StringName in _active_player.player_stats.stats:
		var stat: Stat = _active_player.player_stats.stats[stat_name]
		match stat_name:
			&"max_health":
				match_stats.max_health = stat.value
			&"move_speed":
				match_stats.move_speed = stat.value
			&"armor":
				match_stats.armor = stat.value
			&"crit_chance":
				match_stats.crit_chance = stat.value
			&"crit_damage":
				match_stats.crit_damage = stat.value
			&"health_regen":
				match_stats.health_regen = stat.value
			&"tick_speed":
				match_stats.tick_speed = stat.value
			&"pickup_range":
				match_stats.pickup_range = stat.value
			&"luck":
				match_stats.luck = stat.value
			&"xp_gain":
				match_stats.xp_gain = stat.value
			&"gold_gain":
				match_stats.gold_gain = stat.value
			&"difficulty":
				match_stats.difficulty = stat.value
	_set_state(GameState.GAME_OVER, is_win)


func _set_state(new_state: GameState, is_win: bool = false) -> void:
	if new_state == _state:
		return
	_state = new_state

	match new_state:
		GameState.GAMEPLAY:
			_hide_pause_menu()
			_interface_supervisor.close_building_interface()
			%GameplayScene.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
		GameState.BUILDING:
			_hide_pause_menu()
			_interface_supervisor.open_building_interface()
			%GameplayScene.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
		GameState.LEVEL_UP:
			_hide_pause_menu()
			%GameplayScene.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
			_building_ui.process_mode = PROCESS_MODE_DISABLED
		GameState.PAUSED:
			%GameplayScene.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
			_show_pause_menu()
		GameState.GAME_OVER:
			_hide_pause_menu()
			_interface_supervisor.close_building_interface()
			%GameplayScene.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
			_show_game_over_menu(is_win)
