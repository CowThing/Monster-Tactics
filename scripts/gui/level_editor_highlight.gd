extends Node2D

var highlight_pos = null
var highlight_array = []

onready var field = get_node("../Field")
onready var level_editor = get_node("../../../..")

func get_grid_poly(pos):
	return Vector2Array([
		field.map_to_world(pos),
		field.map_to_world(pos + Vector2(1, 0)),
		field.map_to_world(pos + Vector2(1, 1)),
		field.map_to_world(pos + Vector2(0, 1))
	])

func _draw():
	if highlight_pos != null or highlight_array.size() > 0:
		# Grid
		for i in range(9):
			var s = field.map_to_world(Vector2(i, 0))
			var e = field.map_to_world(Vector2(i, 8))
			draw_line(s, e, Color(1, 1, 1, 0.5))
			
			var s = field.map_to_world(Vector2(0, i))
			var e = field.map_to_world(Vector2(8, i))
			draw_line(s, e, Color(1, 1, 1, 0.5))
		
		#Highlight Array
		for p in highlight_array:
			var v = get_grid_poly(p)
			for i in range(v.size()):
				draw_line(v[i], v[(i + 1) % v.size()], Color("fee761"), 2)
			draw_circle(field.map_to_world_center(p), 8, Color("fee761"))
	
	# Highlight Cursor
	if highlight_pos != null:
		var v = get_grid_poly(highlight_pos)
		for i in range(v.size()):
			draw_line(v[i], v[(i + 1) % v.size()], Color("fee761"), 4)
		
		if level_editor.current_paint_mode == level_editor.PAINT_TILES:
			var pos = v[0] - Vector2(32, 0)
			var tex = level_editor.tileset.tile_get_texture(level_editor.selected_tile)
			var region = level_editor.tileset.tile_get_region(level_editor.selected_tile)
			draw_texture_rect_region(tex, Rect2(pos, region.size), region, Color(1, 1, 1, 0.5))
			
		elif level_editor.current_paint_mode == level_editor.PAINT_UNITS:
			var pos = v[0]
			var tex = level_editor.unitset.tile_get_texture(level_editor.selected_tile)
			var region = level_editor.unitset.tile_get_region(level_editor.selected_tile)
			draw_texture_rect_region(tex, Rect2(pos, region.size), region, Color(1, 1, 1, 0.5))
