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
	
	# Add default maps if they don't exist
	if dir.open("res://maps") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var user_file = file_name.left(file_name.length() - file_name.extension().length() - 1)
				if not dir.file_exists("user://maps/%s.tres" % user_file):
					ResourceSaver.save("user://maps/%s.tres" % user_file, load("res://maps/%s" % file_name))
			
			file_name = dir.get_next()

func get_random_map():
	var list = []
	
	var dir = Directory.new()
	if dir.open("user://maps") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				list.append(load("user://maps/%s" % file_name))
			
			file_name = dir.get_next()
	
	return list[randi() % list.size()]
