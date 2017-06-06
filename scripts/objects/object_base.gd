extends Sprite

var team = 0
var movement_range = 2
var movement = 2
var attack_range = 1
var attack = 10
var defense = 5
var speed = 2
var health = 10
var health_max = 10
var name = "Object"

var aspects = 0

enum aspect {
	FLYING = 1 << 0,
#	BONUS_VS_FLYING = 1 << 1,
#	ARMORED = 1 << 2,
#	BONUS_VS_ARMORED = 1 << 3
}

var map_pos = Vector2()

func _ready():
	health = health_max
	movement = movement_range
	
	set_offset(Vector2(0, -get_texture().get_size().y / 2))
	var mat = CanvasItemMaterial.new()
	mat.set_shader(preload("res://assets/shaders/object_highlight.tres"))
	mat.set_shader_param("outline_color", Color(1,1,1,1))
	mat.set_shader_param("outline_width", 0)
	set_material(mat)
	
	var shadow = Sprite.new()
	shadow.set_texture(preload("res://assets/sprites/unit_shadow.png"))
	shadow.set_draw_behind_parent(true)
	add_child(shadow)
