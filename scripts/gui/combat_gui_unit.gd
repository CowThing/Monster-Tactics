extends Panel

export var right_side = false

var current_unit

func _ready():
	var offset = Vector2(0.25, 0.75) if right_side else Vector2(0.75, 0.75)
	get_node("Back/AttackPos").set_pos(get_node("Back").get_size() * offset)

func set_background(tex):
	get_node("Back").set_texture(tex)

func set_unit(unit):
	current_unit = unit.duplicate()
	current_unit.team = unit.team
	
	get_node("Back").add_child(current_unit)
	current_unit.set_pos(get_node("Back").get_size() * Vector2(0.5, 0.75))
	current_unit.set_scale(Vector2(-1, 1) if right_side else Vector2(1, 1))
	
	get_node("Health").set_max(unit.health_max)
	get_node("Health").set_value(unit.health)

func destroy_unit():
	if current_unit != null:
		current_unit.queue_free()

func damage_health(amnt):
	get_node("Tween").interpolate_property(
		get_node("Health"),
		"range/value",
		get_node("Health").get_value(),
		get_node("Health").get_value() - amnt,
		get_parent().IN_OUT_TIME,
		Tween.TRANS_ELASTIC,
		Tween.EASE_OUT
	)
	get_node("Tween").start()
