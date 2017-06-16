extends Sprite

var team = -1
var health = 1
var health_max = 1

var map_pos = Vector2()

func _ready():
	set_texture(preload("res://assets/sprites/objects/building.png"))
	set_hframes(3)
	set_frame(randi()%3)
	set_offset(Vector2(0, -16))
