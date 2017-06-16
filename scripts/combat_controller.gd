extends Reference

func get_attack_list(attacker, defender, attacker_terrain, defender_terrain):
	# [Unit, Damage]
	var results = []
	
	var attacker_health = attacker.health
	var defender_health = defender.health
	
	results.append([attacker, get_damage(attacker, defender)])
	defender_health -= results[0][1]
	if defender.attack_range == attacker.attack_range and defender_health > 0:
		results.append([defender, get_damage(defender, attacker)])
		attacker_health -= results[1][1]
		if defender.speed >= attacker.speed + 5 and attacker_health > 0:
			results.append([defender, get_damage(defender, attacker)])
			attacker_health -= results[2][1]
	if attacker.speed >= defender.speed + 5 and attacker_health > 0 and defender_health > 0:
		results.append([attacker, get_damage(attacker, defender)])
	
	return results

func get_damage(attacker, defender):
	var attack_bonus = 1
#	if (attacker.aspects & attacker.BONUS_VS_FLYING and defender.aspects & defender.FLYING)\
#	or (attacker.aspects & attacker.BONUS_VS_ARMORED and defender.aspects & defender.ARMORED):
#		attack_bonus = 1.5
	
	var defend_bonus = 1
#	if defender.aspects & defender.ARMORED and not attacker.aspects & attacker.BONUS_VS_ARMORED:
#		defend_bonus = 1.5
	
	return int(attacker.attack * attack_bonus) - int(defender.defense * defend_bonus)