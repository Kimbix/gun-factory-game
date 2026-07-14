class_name StatPillar
extends FactoryComponent

func setup() -> void:
	var info := building.get_info()
	var boost := info.boost_value
	var text := "+%d" % int(boost) if boost == int(boost) else "+%s" % boost
	var s := TextOverlayStrategy.new()
	s.text = text
	overlay_strategy = s
