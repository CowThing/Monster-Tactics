extends Control

onready var tween = get_node("Tween")

signal message_finished

func _input(event):
	if (event.type == InputEvent.KEY or event.type == InputEvent.MOUSE_BUTTON)\
	and event.pressed and not get_tree().is_input_handled():
		tween.seek(max(1.75, tween.tell()))
		get_tree().set_input_as_handled()

func display_message(text):
	get_node("Panel/Label").set_text(text)
	get_node("Panel").set_margin(MARGIN_LEFT, 0)
	get_node("Panel").set_margin(MARGIN_RIGHT, get_viewport_rect().size.x)
	set_process_input(true)
	show()
	
	var window_size = get_viewport_rect().size
	
	tween.interpolate_property(
		get_node("Panel"),
		"margin/right",
		window_size.x,
		0,
		0.25,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	
	tween.interpolate_property(
		get_node("Panel"),
		"margin/left",
		0,
		window_size.x,
		0.25,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT,
		1.75
	)
	
	tween.start()

func _on_Tween_tween_complete( object, key ):
	if tween.tell() >= tween.get_runtime():
		get_node("Panel/Label").set_text("")
		set_process_input(false)
		hide()
		
		emit_signal("message_finished")
