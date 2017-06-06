extends "object_base.gd"

func _init():
	movement_range = 2
	attack_range = 1
	attack = 33
	defense = 30 / 2
	speed = 23
	health_max = 40
	name = "Tank"
	set_texture(preload("res://assets/sprites/units_human/human_tank.png"))
