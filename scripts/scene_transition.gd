extends CanvasLayer

var is_transitioning = false

var scene_queue = []

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

func swap_scene(new_scene):
	if is_transitioning:
		return false
	
	var cur_scene = get_tree().get_current_scene()
	cur_scene.get_parent().remove_child(cur_scene)
	get_tree().set_current_scene(null)
	scene_queue.append(cur_scene)
	
	goto_scene(new_scene)

func return_scene():
	if is_transitioning:
		return false
	
	if not scene_queue.empty():
		is_transitioning = true
		get_node("ColorFrame").show()
		get_node("AnimationPlayer").play("fade_in")
		yield(get_node("AnimationPlayer"), "finished")
		
		get_tree().get_current_scene().queue_free()
		get_tree().get_root().add_child(scene_queue.back())
		get_tree().set_current_scene(scene_queue.back())
		scene_queue.pop_back()
		
		get_node("AnimationPlayer").play_backwards("fade_in")
		yield(get_node("AnimationPlayer"), "finished")
		
		is_transitioning = false
		get_node("ColorFrame").hide()

