extends PopupPanel

func _on_about_to_show():
	get_tree().set_pause(true)

func _on_popup_hide():
	get_tree().set_pause(false)

func _on_ResumeButton_pressed():
	get_tree().get_current_scene().get_node("SFX").play("button")
	hide()

func _on_RestartButton_pressed():
	get_tree().get_current_scene().get_node("SFX").play("button")
	hide()
	scene_transition.goto_scene(load("res://scenes/main.tscn"))

func _on_QuitButton_pressed():
	get_tree().get_current_scene().get_node("SFX").play("button")
	hide()
	
	if get_parent().is_test_mode:
		scene_transition.return_scene()
	else:
		scene_transition.goto_scene(load("res://scenes/mainmenu.tscn"))
