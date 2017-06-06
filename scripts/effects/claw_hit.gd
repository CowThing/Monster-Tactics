extends Node2D

func _ready():
	get_tree().get_current_scene().get_node("SFX").play("hit")
