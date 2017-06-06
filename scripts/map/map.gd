extends Object

var astar
var grid = []
var rect = Rect2()
var field

var neighbor_dirs = [
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(-1, 0),
	Vector2(0, 1)
]

func _init(field):
	self.field = field
	self.astar = preload("res://scripts/map/astar2d.gd").new(self)

func build_map(width, height):
	grid.resize(width * height)
	rect.size = Vector2(width, height)
	
	for i in range(grid.size()):
		var cell = Cell.new()
		cell.id = astar.get_available_point_id()
		cell.pos = index_to_vec(i)
		
		grid[i] = cell
		astar.add_point(cell.id, cell.pos)

func connect_point(pos):
	var cell = get_cell(pos)
	if not cell:
		return
	
	cell.is_connected = true
	
	for dir in neighbor_dirs:
		var check_cell = get_cell(cell.pos + dir)
		if not check_cell:
			continue
		
		if check_cell.is_connected and not are_cells_connected(cell, check_cell):
			astar.connect_points(cell.id, check_cell.id)

func disconnect_point(pos):
	var cell = get_cell(pos)
	if not cell:
		return
	
	cell.is_connected = false
	
	for dir in neighbor_dirs:
		var check_cell = get_cell(cell.pos + dir)
		if not check_cell:
			continue
		
		if are_cells_connected(cell, check_cell):
			astar.disconnect_points(cell.id, check_cell.id)

func get_path(start, end):
	var start_cell = get_cell(start)
	var end_cell = get_cell(end)
	if start_cell and end_cell:
		return astar.get_point_path(start_cell.id, end_cell.id)

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
			
			var next_distance = 1 + distance[current_cell]
			
			if next_distance <= max_distance\
			and not distance.has(next_cell)\
			and are_cells_connected(current_cell, next_cell)\
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

func are_cells_connected(cella, cellb):
	return astar.are_points_connected(cella.id, cellb.id)

func get_cell_id(id):
	return get_cell(astar.get_point_pos(id))

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
	var id = -1
	var type = -1
	var pos = Vector2()
	var is_walkable = true
	var is_connected = false
