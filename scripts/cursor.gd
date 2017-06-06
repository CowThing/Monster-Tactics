extends CanvasLayer

func _ready():
	toggle_cursor(true)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		get_node("Sprite").set_pos(event.pos)
	
	if event.type == InputEvent.MOUSE_BUTTON:
		get_node("Sprite").set_frame(1 if event.pressed else 0)

func toggle_cursor(on):
	if on:
		get_node("Sprite").show()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		set_process_input(true)
		
	else:
		get_node("Sprite").hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_process_input(false)