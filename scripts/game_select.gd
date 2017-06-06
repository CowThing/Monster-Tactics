extends Node

var levels = []

onready var field = preload("res://scenes/field.tscn").instance()

func _ready():
	get_node("Selection/Panel/HBoxContainer/Human/Controller").select(1)
	
	levels = get_levels()
	for level in levels:
		var template = load(level).instance()
		get_node("Selection/Panel/MapSelect").add_item(template.name)
		template.free()
	
	add_child(field)
	
	get_node("Selection/Panel/MapSelect").select(randi() % (get_node("Selection/Panel/MapSelect").get_item_count() - 1))
	field.build_map(load(levels[get_node("Selection/Panel/MapSelect").get_selected()]), false)

func get_levels():
	var dir = Directory.new()
	var level_dir = "res://scenes/levels"
	var results = []
	
	if dir.open(level_dir) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if not file_name.begins_with("level_base"):
					results.append(level_dir + "/" + file_name)
			file_name = dir.get_next()
	
	return results

func _on_MapSelect_item_selected( index ):
	get_node("SFX").play("button")
	remove_child(field)
	field.free()
	field = preload("res://scenes/field.tscn").instance()
	add_child(field)
	field.build_map(load(levels[index]), false)

func _on_StartButton_pressed():
	get_node("SFX").play("button")
	if scene_transition.is_transitioning:
		return
	
	var pl = preload("res://scripts/turn_states/player_turn.gd")
	var cpu = preload("res://scripts/turn_states/cpu_turn.gd")
	var controllers = [pl, cpu]
	
	global.monster_controller = controllers[get_node("Selection/Panel/HBoxContainer/Monster/Controller").get_selected()]
	global.human_controller = controllers[get_node("Selection/Panel/HBoxContainer/Human/Controller").get_selected()]
	global.level = levels[get_node("Selection/Panel/MapSelect").get_selected()]
	
	scene_transition.goto_scene(preload("res://scenes/main.tscn"))

func _on_BackButton_pressed():
	get_node("SFX").play("button")
	scene_transition.goto_scene(load("res://scenes/mainmenu.tscn"))

func _on_Controller_item_selected( index ):
	get_node("SFX").play("button")

func _on_RandomMap_pressed():
	var r = randi() % (get_node("Selection/Panel/MapSelect").get_item_count() - 1)
	get_node("Selection/Panel/MapSelect").select(r)
	_on_MapSelect_item_selected(r)
