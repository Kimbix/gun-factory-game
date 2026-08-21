class_name DamageUtil


static func roll_crit(base_damage: int, player_stats: PlayerStats) -> DamageRoll:
	var was_crit := false
	var final_damage := base_damage
	if player_stats != null and randf() < player_stats.stats[&"crit_chance"].value:
		was_crit = true
		var bonus: float = player_stats.stats[&"crit_damage"].value
		final_damage = ceili(base_damage * (1.0 + bonus))
	return DamageRoll.new(final_damage, was_crit)
