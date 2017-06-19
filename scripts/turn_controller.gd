extends Object

var owner

var teams = []
var current_team = 0

var combat_controller = preload("res://scripts/combat_controller.gd").new()

signal combat_finished
signal turn_start
signal turn_end
signal round_start
signal round_end(winner)

func _init(owner):
	self.owner = owner

func clear_teams():
	for team in teams:
		# Make sure the team isn't a deleted object
		if weakref(team).get_ref():
			team.free()

func start_round(team_a, team_b):
	teams.append(team_a.new())
	teams.append(team_b.new())
	for t in teams:
		t.connect("turn_finished", self, "end_turn", [], CONNECT_DEFERRED)
	
	emit_signal("round_start")
	
	var timer = Timer.new()
	owner.add_child(timer)
	timer.set_wait_time(0.5)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	
	start_turn()

func end_round(winner):
	emit_signal("round_end", winner)
	
	var team_name = "Monster" if winner == 0 else "Human"
	owner.hud.get_node("Message").display_message("%ss have won" % team_name)
	for team in teams:
		team.call_deferred("free")
	teams = []

func remove_current_team():
	owner.remove_child(teams[current_team])

func add_current_team():
	owner.add_child(teams[current_team])

func start_turn():
	teams[current_team].units = get_units_in_team(current_team)
	for unit in teams[current_team].units:
		unit.movement = unit.movement_range
	
	var team_name = "Monster" if current_team == 0 else "Human"
	
	owner.hud.get_node("Message").display_message("%s's turn" % team_name)
	yield(owner.hud.get_node("Message"), "message_finished")
	
	add_current_team()
	emit_signal("turn_start")
	teams[current_team].start_turn()

func end_turn():
	if teams.empty():
		return
	
	remove_current_team()
	emit_signal("turn_end")
	
	current_team = (current_team + 1) % teams.size()
	
	start_turn()

func check_end_round():
	for i in range(teams.size()):
		if get_units_in_team(i).size() == 0:
			print("end round")
			end_round((i + 1) % teams.size())
			return true
	
	return false

func check_end_turn():
	return teams[current_team].units.size() == 0

func get_units_in_team(team_num):
	var results = []
	
	for key in owner.field.objects:
		var obj = owner.field.objects[key]
		if obj.team == team_num:
			results.append(obj)
	
	return results

func object_attack(attacker, attack_pos):
	if teams.empty():
		return false
	
	if not teams[current_team].units.has(attacker):
		call_deferred("emit_signal", "combat_finished")
		return false
	
	if owner.field.can_object_attack(attacker, attack_pos):
		teams[current_team].units.erase(attacker)
		var defender = owner.field.objects[attack_pos]
		
		owner.field.tween.attack_animation(attacker, attack_pos)
		attack_effect(attacker, attack_pos)
		
		if defender.team == -1:
			# Building
			defender.health = clamp(defender.health - 1, 0, defender.health_max)
			if defender.health == 0:
				explosion_effect(defender.get_pos())
				owner.field.free_object(defender)
			
			var timer = Timer.new()
			owner.add_child(timer)
			timer.set_wait_time(0.5)
			timer.start()
			yield(timer, "timeout")
			timer.queue_free()
			
			call_deferred("emit_signal", "combat_finished")
			return false
		
		var terrain_attacker = owner.field.map.get_cell(attacker.map_pos).type
		var terrain_defender = owner.field.map.get_cell(defender.map_pos).type
		var attack_list = combat_controller.get_attack_list(attacker, defender, terrain_attacker, terrain_defender)
		
		remove_current_team()
		owner.hud.get_node("Combat").start_combat(attacker, defender, attack_list, terrain_attacker, terrain_defender)
		yield(owner.hud.get_node("Combat"), "combat_finished")
		add_current_team()
		
		for a in attack_list:
			if a[0] == attacker and attacker.health > 0:
				defender.health = clamp(defender.health - a[1], 0, defender.health_max)
			if a[0] == defender and defender.health > 0:
				attacker.health = clamp(attacker.health - a[1], 0, attacker.health_max)
		
		if attacker.health == 0:
			explosion_effect(attacker.get_pos())
			owner.field.free_object(attacker)
		
		if defender.health == 0:
			explosion_effect(defender.get_pos())
			owner.field.free_object(defender)
		
		call_deferred("emit_signal", "combat_finished")
		check_end_round()

func object_move(obj, move_pos):
	if teams.empty():
		return false
	
	if move_pos in owner.field.map.get_connected_cells(obj.map_pos, obj.movement):
		var start_pos = obj.map_pos
		if owner.field.move_object(obj, move_pos):
			
			var path = owner.field.map.get_path(start_pos, move_pos)
			obj.movement -= owner.field.get_path_cost(obj, path)
			
			if obj.movement <= 0:
				var has_valid_target = false
				for attack_pos in owner.field.map.get_range_cells(obj.map_pos, obj.attack_range):
					if owner.field.objects.has(attack_pos) and owner.field.objects[attack_pos].team != obj.team:
						has_valid_target = true
						break
				
				if not has_valid_target:
					teams[current_team].units.erase(obj)
			
			owner.field.tween.move_animation(obj, path)
			
			return true
	
	return false

func attack_effect(attacker, attack_pos):
	if attacker.team == 0:
		# Monster
		var e = preload("res://scenes/effects/claw_hit.tscn").instance()
		e.set_pos(owner.field.map_to_world_center(attack_pos))
		owner.field.get_node("OnTop").add_child(e)
		
	else:
		# Human
		var e = preload("res://scenes/effects/bullet_hit.tscn").instance()
		e.set_pos(attacker.get_pos())
		owner.field.get_node("OnTop").add_child(e)
		e.shoot(attacker.get_pos(), owner.field.map_to_world_center(attack_pos))

func explosion_effect(pos):
	var e = preload("res://scenes/effects/explosion.tscn").instance()
	e.set_pos(pos)
	owner.field.get_node("OnTop").add_child(e)
