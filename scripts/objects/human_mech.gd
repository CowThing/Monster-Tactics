extends "object_base.gd"

func _init():
	movement_range = 2
	attack_range = 2
	attack = 29
	defense = 24 / 2
	speed = 29
	health_max = 43
	name = "Mech"
	set_texture(preload("res://assets/sprites/units_human/human_mech.png"))
