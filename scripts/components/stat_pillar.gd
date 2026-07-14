class_name StatPillar
extends FactoryComponent

func setup() -> void:
	var cfg := building.get_info().config
	var boost: float = cfg.get("boost_value")
	var text := "+%d" % int(boost) if boost == int(boost) else "+%s" % boost
	var s := TextOverlayStrategy.new()
	s.text = text
	overlay_strategy = s
