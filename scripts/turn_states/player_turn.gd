extends Node2D

var units = []

var selected_object = null
var selected_positions = []
var selected_attackable = []

onready var field = get_parent().field
onready var turn_controller = get_parent().turn_controller

signal turn_finished
signal selected_object_changed(new_object)
signal lock_hover(pos)

func start_turn():
	set_process_unhandled_input(true)

func end_turn():
	set_process_unhandled_input(false)
	deselect_object()
	emit_signal("turn_finished")

func select_object(pos, play_sound=true):
	if not units.has(field.objects[pos]):
		deselect_object()
		return
	
	if play_sound:
		get_tree().get_current_scene().get_node("SFX").play("unit_select")
	
	selected_object = field.objects[pos]
	selected_positions = field.map.get_connected_cells(pos, selected_object.movement)
	selected_attackable = field.get_connected_range_cells(pos, selected_positions, selected_object.attack_range)
	emit_signal("selected_object_changed", selected_object)
	
	little_jump(selected_object)

func deselect_object():
	selected_object = null
	selected_positions = {}
	selected_attackable = []
	emit_signal("selected_object_changed", selected_object)

func _unhandled_input(event):
	if event.type == InputEvent.MOUSE_BUTTON\
	and (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT)\
	and event.is_pressed():
		do_press(get_viewport_transform().xform_inv(event.pos), event.button_index == BUTTON_RIGHT)
	
#	if event.is_action_pressed("ui_accept"):
#		get_tree().set_input_as_handled()
#		end_turn()

func do_press(pos, right_click):
	var target_pos = field.world_to_map(pos)
	
	if right_click:
		if selected_object:
			if selected_positions.has(target_pos):
				# Try to move
				if turn_controller.object_move(selected_object, target_pos):
					select_object(target_pos, false)
					if check_end_turn():
						var timer = Timer.new()
						add_child(timer)
						timer.set_wait_time(0.5)
						timer.start()
						yield(timer, "timeout")
						timer.queue_free()
						end_turn()
				
			elif field.can_object_attack(selected_object, target_pos):
				# Try to attack
				turn_controller.object_attack(selected_object, target_pos)
				deselect_object()
				yield(turn_controller, "combat_finished")
				if check_end_turn():
					end_turn()
				
			elif selected_object.map_pos.distance_to(target_pos) == selected_object.attack_range + 1:
				# Move and attack if a target is within 1 move
				var movepos = selected_object.map_pos + (target_pos - selected_object.map_pos).normalized()
				if turn_controller.object_move(selected_object, movepos):
					select_object(movepos, false)
					
					if field.can_object_attack(selected_object, target_pos):
						turn_controller.object_attack(selected_object, target_pos)
						deselect_object()
						yield(turn_controller, "combat_finished")
						if check_end_turn():
							end_turn()
		
	else:
		if field.objects.has(target_pos) and units.has(field.objects[target_pos]):
			# Select object if it's on our team
			select_object(target_pos)
			
		else:
			# Otherwise lock or unlock hover unit
			emit_signal("lock_hover", target_pos)
			
			if not field.objects.has(target_pos)\
			or (field.objects.has(target_pos) and field.objects[target_pos].team == -1):
				# If clicked on no unit or building deselect object
				deselect_object()

func check_end_turn():
	for obj in units:
		if obj.movement <= 0:
			var has_valid_target = false
			for attack_pos in field.map.get_range_cells(obj.map_pos, obj.attack_range):
				if field.objects.has(attack_pos) and field.objects[attack_pos].team != obj.team:
					has_valid_target = true
					break
			
			if not has_valid_target:
				units.erase(obj)
	
	return units.size() == 0

func little_jump(obj):
	var obj_ref = weakref(obj)
	obj.set_offset(obj.get_offset() - Vector2(0, 2))
	
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.25)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	
	if obj_ref.get_ref():
		obj.set_offset(obj.get_offset() + Vector2(0, 2))
