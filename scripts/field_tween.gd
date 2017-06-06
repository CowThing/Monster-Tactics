extends Tween

onready var field = get_parent()

signal animation_complete

func move_animation(obj, path):
	var delay = 0
	for i in range(path.size()):
		if i > 0:
			var start = field.map_to_world_center(path[i - 1])
			var end = field.map_to_world_center(path[i])
			var time = start.distance_to(end) / 128
			
			interpolate_property(
				obj,
				"transform/pos",
				start,
				end,
				time,
				Tween.TRANS_LINEAR if i > 1 and i < path.size() - 1 else Tween.TRANS_BACK,
				Tween.EASE_IN if i < path.size() - 1 else Tween.EASE_OUT,
				delay
			)
			
			delay += time
	
	start()

func attack_animation(attacker, attack_pos):
	var start = field.map_to_world_center(attacker.map_pos)
	var end = start + (field.map_to_world_center(attack_pos) - start).normalized() * field.get_cell_size() * 0.5
	var time = 0.25
	
	interpolate_property(
		attacker,
		"transform/pos",
		start,
		end,
		time,
		Tween.TRANS_BACK,
		Tween.EASE_OUT,
		0
	)
	interpolate_property(
		attacker,
		"transform/pos",
		end,
		start,
		time,
		Tween.TRANS_BACK,
		Tween.EASE_OUT,
		time
	)
	
	start()

func _on_tween_complete( object, key ):
	if tell() >= get_runtime():
		call_deferred("emit_signal", "animation_complete")
