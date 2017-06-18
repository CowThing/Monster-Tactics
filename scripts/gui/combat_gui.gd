extends Control

const IN_OUT_TIME = 0.5
const ATTACK_TIME = 1.0

var backgrounds = [
	preload("res://assets/sprites/backgrounds/field.png"),
	preload("res://assets/sprites/backgrounds/rubble.png"),
	preload("res://assets/sprites/backgrounds/water.png"),
	preload("res://assets/sprites/backgrounds/road.png"),
	preload("res://assets/sprites/backgrounds/forest.png")
]

onready var tween = get_node("Tween")

signal combat_start
signal combat_finished

func _input(event):
	if (event.type == InputEvent.KEY or event.type == InputEvent.MOUSE_BUTTON)\
	and event.pressed and not get_tree().is_input_handled():
		tween.seek(max(tween.get_runtime() - IN_OUT_TIME, tween.tell()))
		get_tree().set_input_as_handled()

func start_combat(attacker, defender, attack_list, terrain_attacker=0, terrain_defender=0):
	show()
	set_process_input(true)
	
	var window_size = get_viewport_rect().size
	
	get_node("PanelLeft").set_margin(MARGIN_RIGHT, window_size.x / 2)
	get_node("PanelRight").set_margin(MARGIN_LEFT, -window_size.x / 2)
	
	get_node("PanelLeft").set_unit(attacker)
	get_node("PanelLeft").set_background(backgrounds[terrain_attacker])
	get_node("PanelRight").set_unit(defender)
	get_node("PanelRight").set_background(backgrounds[terrain_defender])
	
	var out_delay = IN_OUT_TIME + (attack_list.size() * ATTACK_TIME)
	
	# Panel Left
	tween.interpolate_property(
		get_node("PanelLeft"),
		"margin/right",
		window_size.x / 2,
		0,
		IN_OUT_TIME * 0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)
	
	tween.interpolate_property(
		get_node("PanelLeft"),
		"margin/right",
		0,
		window_size.x / 2,
		IN_OUT_TIME * 0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_IN,
		out_delay
	)
	
	# Panel Right
	tween.interpolate_property(
		get_node("PanelRight"),
		"margin/left",
		- window_size.x / 2,
		0,
		IN_OUT_TIME * 0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)
	
	tween.interpolate_property(
		get_node("PanelRight"),
		"margin/left",
		0,
		- window_size.x / 2,
		IN_OUT_TIME * 0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_IN,
		out_delay
	)
	
	#Background
	tween.interpolate_property(
		get_node("Background"),
		"visibility/opacity",
		0,
		1,
		IN_OUT_TIME,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
	tween.interpolate_property(
		get_node("Background"),
		"visibility/opacity",
		1,
		0,
		IN_OUT_TIME,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT,
		out_delay
	)
	
	# Attacks
	for i in range(attack_list.size()):
		var a = attack_list[i]
		var attack_panel = get_node("PanelLeft")
		var damaged_panel = get_node("PanelRight")
		if a[0] == defender:
			attack_panel = get_node("PanelRight")
			damaged_panel = get_node("PanelLeft")
		
		var time = IN_OUT_TIME + (i * ATTACK_TIME)
		
		# Damage Health
		tween.interpolate_callback(
			damaged_panel,
			time,
			"damage_health",
			a[1]
		)
		
		# Create effect
		tween.interpolate_callback(
			self,
			time,
			"attack_effect",
			attack_panel.current_unit,
			damaged_panel.current_unit
		)
		
		# Attack animation
		var start = attack_panel.current_unit.get_pos()
		var end = start + (attack_panel.get_node("Back/AttackPos").get_pos() - start).normalized() * Vector2(64, 64)
		
		tween.interpolate_property(
			attack_panel.current_unit,
			"transform/pos",
			start,
			end,
			0.25,
			Tween.TRANS_BACK,
			Tween.EASE_OUT,
			time
		)
		tween.interpolate_property(
			attack_panel.current_unit,
			"transform/pos",
			end,
			start,
			0.25,
			Tween.TRANS_BACK,
			Tween.EASE_OUT,
			time + 0.25
		)
	
	tween.start()
	emit_signal("combat_start")

func attack_effect(attacker, defender):
	if attacker.team == 0:
		# Monster
		var e = preload("res://scenes/effects/claw_hit.tscn").instance()
		e.set_pos(defender.get_global_pos())
		get_node("Effects").add_child(e)
		
	else:
		# Human
		var e = preload("res://scenes/effects/bullet_hit.tscn").instance()
		e.set_pos(attacker.get_global_pos())
		get_node("Effects").add_child(e)
		e.shoot(attacker.get_global_pos(), defender.get_global_pos())

func _on_tween_complete( object, key ):
	if tween.tell() >= tween.get_runtime():
		tween.remove_all()
		get_node("PanelLeft").destroy_unit()
		get_node("PanelRight").destroy_unit()
		set_process_input(false)
		hide()
		emit_signal("combat_finished")
