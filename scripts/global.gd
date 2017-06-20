extends Node

var monster_controller
var human_controller
var level

func _ready():
	randomize()
	
	# Create maps folder if it doesn't exist
	var dir = Directory.new()
	if dir.open("user://") == OK:
		if not dir.dir_exists("maps"):
			dir.make_dir("maps")

func create_timer(delay):
	var t = Timer.new()
	t.set_wait_time(delay)
	t.set_one_shot(true)
	add_child(t)
	
	t.connect("timeout", t, "queue_free")
	t.start()
	return t

func get_user_maps():
	var list = []
	
	var dir = Directory.new()
	if dir.open("user://maps") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				list.append(load("user://maps/%s" % file_name))
			
			file_name = dir.get_next()
	
	return list

func get_default_maps():
	var list = []
	
	var dir = Directory.new()
	if dir.open("res://maps") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				list.append(load("res://maps/%s" % file_name))
			
			file_name = dir.get_next()
	
	return list

func get_random_map():
	var list = get_default_maps() + get_user_maps()
	return list[randi() % list.size()]
