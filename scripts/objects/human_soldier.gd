extends "object_base.gd"

func _init():
	movement_range = 2
	attack_range = 1
	attack = 27
	defense = 20 / 2
	speed = 36
	health_max = 38
	name = "Soldier"
	set_texture(preload("res://assets/sprites/units_human/human_soldier.png"))
