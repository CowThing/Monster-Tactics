extends Node2D

func _ready():
	get_tree().get_current_scene().get_node("SFX").play("hit")

func shoot(start_pos, end_pos):
	var tween = get_node("Tween")
	tween.interpolate_method(
		get_node("Bullet"),
		"set_global_pos",
		start_pos + Vector2(0, -24),
		end_pos + Vector2(0, -24),
		start_pos.distance_to(end_pos) / 480.0,
		tween.TRANS_LINEAR,
		tween.EASE_IN
	)
	tween.start()
	
	get_node("Bullet").set_rot((end_pos - start_pos).angle() + PI)

func _on_tween_complete( object, key ):
	queue_free()
