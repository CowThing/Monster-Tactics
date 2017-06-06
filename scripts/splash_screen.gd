extends Control

func _ready():
	music_player.play_music("menu")
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY or event.type == InputEvent.MOUSE_BUTTON:
		get_node("Timer").stop()
		_on_Timer_timeout()

func _on_Timer_timeout():
	scene_transition.goto_scene(load("res://scenes/mainmenu.tscn"))
