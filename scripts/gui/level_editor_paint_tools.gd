extends Reference

enum tool_types {TOOL_PENCIL, TOOL_FLOOD, TOOL_LINE, TOOL_RECTANGLE}

var selected_tool
var eraser
var owner

func _init(owner):
	self.owner = owner
	
	eraser = PencilTool.new()
	eraser.owner = self
	eraser.map = owner.current_map
	
	set_selected_tool(TOOL_PENCIL)

func set_selected_tool(type):
	if type == TOOL_PENCIL:
		selected_tool = PencilTool.new()
		
	elif type == TOOL_FLOOD:
		selected_tool = FloodTool.new()
		
	elif type == TOOL_LINE:
		selected_tool = LineTool.new()
		
	elif type == TOOL_RECTANGLE:
		selected_tool = RectangleTool.new()
	
	selected_tool.owner = self
	selected_tool.map = owner.current_map

func paint(pos, painter):
	owner.paint_tile(pos, painter.tile_type)

func highlight(arr):
	owner.highlight.highlight_array = arr
	owner.highlight.update()

func update_map():
	owner.update_map()

class BaseTool:
	var owner
	var map
	var start_pos = Vector2()
	var current_pos = Vector2()
	var tile_type = -1
	
	func start(pos, type):
		start_pos = pos
		current_pos = pos
		tile_type = type
		_start(pos)
	
	func _start(pos):
		pass
	
	func update(pos):
		current_pos = pos
		_update(pos)
	
	func _update(pos):
		pass
	
	func finish(pos):
		current_pos = pos
		owner.highlight([])
		_finish(pos)
	
	func _finish(pos):
		pass

class PencilTool extends BaseTool:
	# Basic drawing tool
	func _start(pos):
		owner.paint(pos, self)
	
	func _update(pos):
		owner.paint(pos, self)
		owner.update_map()

class FloodTool extends BaseTool:
	# Fill all connected tiles of the same type
	var neighbor_dirs = [
		Vector2(1, 0),
		Vector2(0, -1),
		Vector2(-1, 0),
		Vector2(0, 1)
	]
	
	func _start(pos):
		owner.highlight(fill_points())
	
	func _update(pos):
		owner.highlight(fill_points())
	
	func _finish(pos):
		for p in fill_points():
			owner.paint(p, self)
	
	func fill_points():
		if not map.rect.has_point(current_pos):
			return []
		
		var target_tile = map.get_tile(current_pos)
		if target_tile == tile_type:
			return []
		
		var frontier = [current_pos]
		var points = [current_pos]
		while not frontier.empty():
			var pos = frontier.front()
			frontier.pop_front()
			
			for dir in neighbor_dirs:
				var next_pos = pos + dir
				if not map.rect.has_point(next_pos):
					continue
				
				if not points.has(next_pos) and map.get_tile(next_pos) == target_tile:
					frontier.append(next_pos)
					points.append(next_pos)
		
		return points

class LineTool extends BaseTool:
	# Draw line from start to finish
	func _start(pos):
		owner.highlight(line())
	
	func _update(pos):
		owner.highlight(line())
	
	func _finish(pos):
		for p in line():
			owner.paint(p, self)
	
	func distance(a, b):
		return max(abs(b.x - a.x), abs(b.y - a.y))
	
	func round_vector(vec):
		return Vector2(round(vec.x), round(vec.y)).floor()
	
	func line():
		var points = []
		var n = distance(start_pos, current_pos)
		for i in range(n + 1):
			var t = 0 if n == 0 else float(i) / n
			var target = round_vector(start_pos.linear_interpolate(current_pos, t))
			if map.rect.has_point(target):
				points.append(target)
		
		return points

class RectangleTool extends BaseTool:
	# Draw rectangle from start to finish
	func _start(pos):
		owner.highlight(rect_points())
	
	func _update(pos):
		owner.highlight(rect_points())
	
	func _finish(pos):
		for p in rect_points():
			owner.paint(p, self)
	
	func rect_points():
		var points = []
		var rect = Rect2(start_pos, Vector2())
		rect = rect.expand(current_pos)
		rect.size += Vector2(1, 1)
		
		for x in range(rect.size.x):
			for y in range(rect.size.y):
				var target = Vector2(x, y) + rect.pos
				if map.rect.has_point(target):
					points.append(target)
		
		return points
