extends CanvasLayer

var is_transitioning = false

func _ready():
	get_node("AnimationPlayer").play_backwards("fade_in")

func goto_scene(new_scene):
	if is_transitioning:
		return false
	
	is_transitioning = true
	get_node("ColorFrame").show()
	get_node("AnimationPlayer").play("fade_in")
	yield(get_node("AnimationPlayer"), "finished")
	
	get_tree().change_scene_to(new_scene)
	
	get_node("AnimationPlayer").play_backwards("fade_in")
	yield(get_node("AnimationPlayer"), "finished")
	
	is_transitioning = false
	get_node("ColorFrame").hide()
