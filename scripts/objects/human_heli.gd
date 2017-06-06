extends "object_base.gd"

func _init():
	movement_range = 2
	attack_range = 1
	attack = 30
	defense = 26 / 2
	speed = 30
	health_max = 40
	name = "Helicopter"
	aspects = FLYING
	set_texture(preload("res://assets/sprites/units_human/human_heli.png"))
