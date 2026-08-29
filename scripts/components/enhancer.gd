class_name Enhancer
extends FactoryComponent

var _config: EnhancerConfig
var _stored_info: FactoryItemInfo = null
var _active_entry: EnhancementEntry = null
var _craft_progress: int = 0
var _existing_effects: Array[EffectStrategy] = []
var _stored_shooting_strategy: ShootingStrategy = null


func setup() -> void:
	_config = building.get_info().config as EnhancerConfig


func receive_item(item: FactoryItem) -> void:
	var g := grid
	if g == null:
		return
	var entry := _config.catalogue.find_entry(item.name)
	if entry == null:
		g.destroy_item(item)
		return
	var new_effect: EffectStrategy = entry.effect_script.new()
	if not new_effect.is_compatible_with(item.effects):
		g.destroy_item(item)
		return
	_stored_info = item.get_info()
	_active_entry = entry
	_existing_effects = item.effects.duplicate()
	_stored_shooting_strategy = item.shooting_strategy
	_craft_progress = 0
	g.destroy_item(item)
	_update_overlay()


func tick() -> void:
	if _stored_info == null or _active_entry == null:
		return
	if not _can_output():
		return
	_craft_progress += 1
	_notify_progress(_craft_progress, _active_entry.craft_time)
	if _craft_progress >= _active_entry.craft_time:
		if _output_item(_stored_info):
			_stored_info = null
			_active_entry = null
			_craft_progress = 0
			_existing_effects.clear()
			_stored_shooting_strategy = null
			_update_overlay()


func get_vars() -> Dictionary[StringName, Variant]:
	return {
		&"_stored_info": _stored_info,
		&"_active_entry": _active_entry,
		&"_craft_progress": _craft_progress,
	}


func set_var(n: StringName, v: Variant) -> void:
	match n:
		&"_stored_info":
			_stored_info = v
		&"_active_entry":
			_active_entry = v
		&"_craft_progress":
			_craft_progress = v
		_:
			super.set_var(n, v)


func _configure_output_item(item: FactoryItem) -> void:
	item.shooting_strategy = _stored_shooting_strategy
	item.effects = _existing_effects.duplicate()
	if _active_entry != null and _active_entry.effect_script != null:
		item.effects.append(_active_entry.effect_script.new())


func _update_overlay() -> void:
	if _stored_info == null:
		overlay_strategy = null
		return
	var s := ItemOverlayStrategy.new()
	s.item_info = _stored_info
	overlay_strategy = s
