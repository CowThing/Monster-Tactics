extends Object

var grid = []
var rect = Rect2()
var field

enum tile_types {TILE_GRASS, TILE_BUILDING, TILE_WATER, TILE_ROAD, TILE_FOREST}

var neighbor_dirs = [
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(-1, 0),
	Vector2(0, 1)
]

func _init(field):
	self.field = field

func build_map(width, height):
	grid.resize(width * height)
	rect.size = Vector2(width, height)
	
	for i in range(grid.size()):
		if not get_cell(index_to_vec(i)):
			var cell = Cell.new()
			cell.pos = index_to_vec(i)
			
			grid[i] = cell

func get_path(start_pos, end_pos):
	var start_cell = get_cell(start_pos)
	var end_cell = get_cell(end_pos)
	if not start_cell or not end_cell:
		return
	
	var frontier = [[start_cell, 0]]
	var came_from = {}
	var cost_so_far = {}
	came_from[start_cell] = null
	cost_so_far[start_cell] = 0
	
	while not frontier.empty():
		var current_cell = frontier.front()[0]
		frontier.pop_front()
		
		if current_cell == end_cell:
			break
		
		for dir in neighbor_dirs:
			var next_cell = get_cell(current_cell.pos + dir)
			if not next_cell:
				continue
			
			var new_cost = field.connected_cost(start_cell, next_cell) + cost_so_far[current_cell]
			
			if field.can_pass(start_cell, next_cell)\
			and (not cost_so_far.has(next_cell) or new_cost < cost_so_far[next_cell]):
				cost_so_far[next_cell] = new_cost
				
				frontier.append([next_cell, new_cost])
				frontier.sort_custom(self, "_sort_priority")
				
				came_from[next_cell] = current_cell
	
	var results = [end_cell.pos]
	var current_cell = end_cell
	while current_cell != start_cell:
		if not came_from.has(current_cell):
			return []
			
		current_cell = came_from[current_cell]
		results.push_front(current_cell.pos)
	
	return results

func _sort_priority(a, b):
	return a[1] < b[1]

func get_connected_cells(start_pos, max_distance):
	var start_cell = get_cell(start_pos)
	if not start_cell:
		return
	
	var frontier = [start_cell]
	var distance = {start_cell : 0}
	while not frontier.empty():
		var current_cell = frontier.front()
		frontier.pop_front()
		
		for dir in neighbor_dirs:
			var next_cell = get_cell(current_cell.pos + dir)
			if not next_cell:
				continue
			
			var next_distance = field.connected_cost(start_cell, next_cell) + distance[current_cell]
			
			if next_distance <= max_distance\
			and not distance.has(next_cell)\
			and field.can_pass(start_cell, next_cell):
				frontier.append(next_cell)
				distance[next_cell] = next_distance
	
	var results = []
	for key in distance:
		results.append(key.pos)
	
	return results

func get_range_cells(start_pos, cell_range):
	var results = Vector2Array()
	
	for dir in neighbor_dirs:
		var current_pos = dir * cell_range
		for i in range(cell_range):
			if rect.has_point(start_pos + current_pos):
				results.append(start_pos + current_pos)
			
			current_pos += dir.rotated(deg2rad(135)).snapped(Vector2(1, 1))
	
	return results

func get_cell(pos):
	if rect.has_point(pos):
		return grid[vec_to_index(pos)]

func index_to_vec(i):
	var width = int(rect.size.width)
	return Vector2(i % width, int(i / width))

func vec_to_index(vec):
	var width = int(rect.size.width)
	return (vec.y * width) + vec.x

class Cell:
	var type = -1
	var pos = Vector2()
	var is_walkable = true
	var is_connected = false
