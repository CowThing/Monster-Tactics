extends Node2D

var units = []

onready var field = get_parent().field
onready var turn_controller = get_parent().turn_controller

signal turn_finished

func start_turn():
	var start_time = OS.get_ticks_msec()
	
	var enemies = []
	for u in field.objects.values():
		if u.team != turn_controller.current_team:
			enemies.append(u.map_pos)
	
	var actions = []
	
	for unit in units:
		var positions = field.map.get_connected_cells(unit.map_pos, unit.movement)
		var attackable = field.get_connected_range_cells(unit.map_pos, positions, unit.attack_range)
		
		for enemy in enemies:
			var enemy_team = field.objects[enemy].team
			
			if field.can_object_attack(unit, enemy):
				# Attack object directly next to
				var priority = 1 + (randf() * 0.1)
				
				if enemy_team == -1:
					priority *= 0.25 if turn_controller.current_team == 0 else 0.1
				
				actions.append(action_attack(unit, enemy, priority))
			
			if enemy in positions or enemy in attackable:
				# Attack object within walking distance
				for pos in field.map.get_range_cells(enemy, unit.attack_range):
					if pos in positions:
						var path = field.map.get_path(unit.map_pos, pos)
						
						var x = (path.size() - 1) / float(unit.movement_range)
						var priority = (0.5 * -x) + 1
						priority += randf() * 0.1
						
						if enemy_team == -1:
							priority *= 0.35 if turn_controller.current_team == 0 else 0.1
						
						actions.append(action_move_and_attack(unit, pos, enemy, priority))
			
			if enemy_team != -1:
				# Walk towards enemy
				var path = field.map.get_path(unit.map_pos, enemy)
				var max_distance = 99 if global.monster_controller == global.human_controller else 6
				
				if path.size() <= max_distance:
					for i in range(path.size()-1, 0, -1):
						if path[i] in positions:
							
							var x = (i / 2.0)
							var priority = 0.25 * x
							priority += randf() * 0.1
							
							actions.append(action_move(unit, path[i], priority))
			
			actions.append(action_none(unit, randf() * 0.15))
	
	actions.sort_custom(self, "sort_actions")
	actions.invert()
	
	var unit_actions = {}
	for action in actions:
		if not unit_actions.has(action.unit):
			var current_move_target
			for a in action.list:
				if a.function == "object_move":
					current_move_target = a.target
			
			if current_move_target == null:
				unit_actions[action.unit] = action.list
				continue
			
			var can_use = true
			for old_unit in unit_actions:
				if old_unit.map_pos == current_move_target:
					can_use = false
					break
				
				for a in unit_actions[old_unit]:
					if a.function == "object_move":
						if a.target == current_move_target:
							can_use = false
			
			if can_use:
				unit_actions[action.unit] = action.list
	
	print("cpu time: ", OS.get_ticks_msec() - start_time)
	
	for unit in unit_actions:
		for action in unit_actions[unit]:
			var ret = turn_controller.call(action.function, unit, action.target)
			if action.function == "object_move":
				if ret:
					# Can move
					var timer = Timer.new()
					add_child(timer)
					timer.set_wait_time(0.5)
					timer.start()
					yield(timer, "timeout")
					timer.queue_free()
				
			else:
				if ret != null and typeof(ret) != TYPE_BOOL and ret extends GDFunctionState:
					# Can attack
					yield(turn_controller, "combat_finished")
	
	emit_signal("turn_finished")

func sort_actions(a, b):
	return a.priority < b.priority

func action_none(unit, priority = 0):
	var results = {
		unit = unit,
		priority = priority,
		list = []
	}
	return results

func action_move_and_attack(unit, position, attack_pos, priority = 0.5):
	var results = {
		unit = unit,
		priority = priority,
		list = [{function = "object_move", target = position}, {function = "object_attack", target = attack_pos}]
	}
	return results

func action_move(unit, position, priority = 0.25):
	var results = {
		unit = unit,
		priority = priority,
		list = [{function = "object_move", target = position}]
	}
	return results

func action_attack(unit, attack_pos, priority = 1):
	var results = {
		unit = unit,
		priority = priority,
		list = [{function = "object_attack", target = attack_pos}]
	}
	return results
