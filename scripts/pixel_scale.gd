extends Node

onready var root = get_tree().get_root()
onready var base_size = root.get_rect().size

var bartex = preload("res://assets/sprites/gui/black_bar.png")

func _ready():
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	
	root.set_size_override_stretch(false)
	root.set_size_override(false, Vector2())
	root.set_as_render_target(true)
	root.set_render_target_update_mode(root.RENDER_TARGET_UPDATE_ALWAYS)
	root.set_render_target_to_screen_rect(root.get_rect())
	
	VisualServer.black_bars_set_images(bartex.get_rid(), bartex.get_rid(), bartex.get_rid(), bartex.get_rid())

func _on_screen_resized():
	var new_window_size = OS.get_window_size()
	
	var scale_w = max(int(new_window_size.x / base_size.x), 1)
	var scale_h = max(int(new_window_size.y / base_size.y), 1)
	var scale = min(scale_w, scale_h)
	
	var diff = new_window_size - (base_size * scale)
	var diffhalf = (diff * 0.5).floor()
	
	root.set_rect(Rect2(Vector2(), base_size))
	root.set_render_target_to_screen_rect(Rect2(diffhalf, base_size * scale))
	
	var odd_offset = Vector2(int(new_window_size.x) % 2, int(new_window_size.y) % 2)
	VisualServer.black_bars_set_margins(diffhalf.x, diffhalf.y, diffhalf.x + odd_offset.x, diffhalf.y + odd_offset.y)
