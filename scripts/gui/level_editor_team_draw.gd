extends Node2D

onready var field = get_node("../Field")
onready var level_editor = get_node("../../../..")

func _draw():
	for i in range(level_editor.teams_pos.size()):
		var team = level_editor.teams_pos[i]
		for pos in team:
			if pos != null:
				var world_pos = field.map_to_world(pos)
				var tex = level_editor.unitset.tile_get_texture(i)
				var region = level_editor.unitset.tile_get_region(i)
				draw_texture_rect_region(tex, Rect2(world_pos, region.size), region)
