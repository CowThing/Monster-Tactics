extends Control

var current_unit = null

func _ready():
	# Make texture unique
	get_node("Name/RangeIcon").set_texture(get_node("Name/RangeIcon").get_texture().duplicate())

func set_unit(new_unit):
	current_unit = new_unit
	if current_unit == null:
		get_node("Name").set_text("")
		get_node("Label").set_text("")
		hide()
		return
	
	show()
	
	get_node("Icon").set_texture(current_unit.get_texture())
	get_node("Name").set_text(current_unit.name)
	
	get_node("Name/RangeIcon").get_texture().set_region(Rect2(0, 0, 16, 16)\
	if current_unit.attack_range == 1 else Rect2(16, 0, 16, 16))
	get_node("Name/RangeIcon").set_tooltip("Melee Attack"\
	if current_unit.attack_range == 1 else "Ranged Attack")
	get_node("Name/RangeIcon").update()
	
	get_node("Name/FlyIcon").set_hidden(not bool(current_unit.aspects & current_unit.aspect.FLYING))
	
	var hp = "HP %d/%d" % [current_unit.health, current_unit.health_max]
	get_node("Name/HealthBar").set_max(current_unit.health_max)
	get_node("Name/HealthBar").set_value(current_unit.health)
	get_node("Name/HealthBar/Label").set_text(hp)
	
	var text = """Attack: %s
Attack Range: %s
Defense: %s
Movement: %s
Speed: %s""" % [
		current_unit.attack,
		current_unit.attack_range,
		current_unit.defense,
		current_unit.movement_range,
		current_unit.speed
	]
	get_node("Label").set_text(text)
