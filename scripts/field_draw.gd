extends Node2D

var highlight_sprite = preload("res://assets/sprites/tiles/highlight.png")

var selected_object = null
var selected_positions = {}
var selected_attackable = []
var hover_pos = null setget set_hover_pos

onready var field = get_parent()

func update_selected(selected_object, selected_positions, selected_attackable):
	self.selected_object = selected_object
	self.selected_positions = selected_positions
	self.selected_attackable = selected_attackable
	update()

func set_hover_pos(pos):
	if hover_pos != null and field.objects.has(hover_pos):
		field.objects[hover_pos].get_material().set_shader_param("outline_width", 0)
	
	hover_pos = pos
	update()
	
	if (selected_object\
	and field.objects.has(pos)\
	and field.objects[pos].team != selected_object.team\
	and selected_object.map_pos.distance_to(pos) == selected_object.attack_range + 1\
	and not field.objects.has(selected_object.map_pos + (pos - selected_object.map_pos).normalized()))\
	or (selected_object and field.can_object_attack(selected_object, pos)):
		field.objects[pos].get_material().set_shader_param("outline_width", 1)

func _draw():
	for pos in selected_positions:
		var rect = Rect2(field.map_to_world(pos), Vector2(96, 32))
		rect.pos.x -= 32
		var offset = Rect2(96, 0, 96, 32)
		offset.pos = Vector2(0, 0) if pos == selected_object.map_pos else offset.pos
		var color = Color(1, 1, 1)
		color.a = 0.5 if field.objects.has(pos) else 1
		draw_texture_rect_region(highlight_sprite, rect, offset, color)
	
	for pos in selected_attackable:
		var rect = Rect2(field.map_to_world(pos), Vector2(96, 32))
		rect.pos.x -= 32
		draw_texture_rect_region(highlight_sprite, rect, Rect2(192, 0, 96, 32))
	
	if hover_pos != null:
		var rect = Rect2(field.map_to_world(hover_pos), Vector2(96, 32))
		rect.pos.x -= 32
		draw_texture_rect_region(highlight_sprite, rect, Rect2(0, 0, 96, 32))
		
#		var unit = field.objects[hover_pos] if field.objects.has(hover_pos) else null
#		if unit:
#			var range_tiles = field.map.get_range_cells(unit.map_pos, unit.attack_range)
#			for pos in range_tiles:
#				if selected_positions.has(pos):
#					continue
#				
#				var rect = Rect2(field.map_to_world(pos), Vector2(96, 32))
#				rect.pos.x -= 32
#				draw_texture_rect_region(highlight_sprite, rect, Rect2(288, 0, 96, 32))
