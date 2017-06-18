extends TileMap

var monster_units = [
	preload("res://scripts/objects/monster_a.gd"),
	preload("res://scripts/objects/monster_b.gd"),
	preload("res://scripts/objects/monster_d.gd"),
	preload("res://scripts/objects/monster_c.gd")
]

var human_units = [
	preload("res://scripts/objects/human_soldier.gd"),
	preload("res://scripts/objects/human_heli.gd"),
	preload("res://scripts/objects/human_tank.gd"),
	preload("res://scripts/objects/human_mech.gd")
]

var map = preload("res://scripts/map/map.gd").new(self)
var objects = {}
var scenery = []

var floor_offset = Vector2(0, 16)

onready var tween = get_node("Tween")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		map.free()

func build_map(template, spawn_units=true):
	var rect = template.rect
	map.build_map(rect.size.x, rect.size.y)
	
	clear_objects()
	clear_scenery()
	
	# Map tiles
	for i in range(map.grid.size()):
		var cell = map.grid[i]
		var tile = template.get_tile(cell.pos)
		cell.type = tile
		map.connect_point(cell.pos)
		
		if tile == map.TILE_BUILDING:
			var build = preload("res://scripts/objects/building.gd").new()
			add_object(build, cell.pos)
			
		if tile == map.TILE_WATER:
			cell.is_walkable = false
			
		if tile == map.TILE_FOREST:
			var tree_offsets = [Vector2(-8, -8), Vector2(16, -8), Vector2(8, 8), Vector2(-16, 8)]
			for i in range(4):
				var tree = Sprite.new()
				tree.set_texture(preload("res://assets/sprites/objects/tree.png"))
				tree.set_hframes(2)
				tree.set_frame(randi() % 2)
				tree.set_offset(Vector2(0, -8))
				add_scenery(tree, cell.pos)
				
				var rand_pos = Vector2(randi() % 8, randi() % 8) - Vector2(4, 4)
				tree.set_pos(tree.get_pos() + tree_offsets[i] + rand_pos)
	
	# Visual tiles
	for i in range(map.grid.size()):
		var cell = map.grid[i]
		var tile = cell.type
		
		var visual_tile = -1
		if tile == map.TILE_GRASS or tile == map.TILE_FOREST:
			visual_tile = randi()%4
			
		elif tile == map.TILE_BUILDING:
			visual_tile = 4
			
		elif tile == map.TILE_ROAD:
			var count = 0
			for i in range(map.neighbor_dirs.size()):
				var dir = map.neighbor_dirs[i]
				var check_cell = map.get_cell(cell.pos + dir)
				if not check_cell:
					continue
				
				if check_cell.type == 3:
					count |= 1 << i
			
			visual_tile = count + 5 # Road tile offset
		
		set_cellv(cell.pos, visual_tile)
	
	# Map units
	if spawn_units:
		var team_monster_count = 0
		var team_human_count = 0
		for pos in template.units:
			if template.get_team_pos(pos) == 0:
				var obj = monster_units[team_monster_count % monster_units.size()].new()
				obj.team = 0
				add_object(obj, pos)
				
				team_monster_count += 1
			else:
				var obj = human_units[team_human_count % human_units.size()].new()
				obj.team = 1
				add_object(obj, pos)
				
				team_human_count += 1
	
	get_node("Camera2D").set_pos(map_to_world(map.rect.size * 0.5))

func move_object(obj, to_pos):
	if not map.rect.has_point(to_pos) or objects.has(to_pos):
		return false
	
	get_parent().get_node("SFX").play("walk")
	
	objects.erase(obj.map_pos)
	objects[to_pos] = obj
	obj.map_pos = to_pos
	
	return true

func can_object_attack(obj, attack_pos):
	return objects.has(attack_pos)\
		and objects[attack_pos].team != obj.team\
		and attack_pos in map.get_range_cells(obj.map_pos, obj.attack_range)

func get_object(world_pos):
	var map_pos = world_to_map(world_pos)
	if objects.has(map_pos):
		return objects[map_pos]

func add_object(obj, pos):
	obj.set_pos(map_to_world_center(pos))
	objects[pos] = obj
	obj.map_pos = pos
	get_node("OnTop").add_child(obj)

func free_object(obj):
	objects.erase(obj.map_pos)
	obj.queue_free()

func clear_objects():
	for obj in objects.values():
		free_object(obj)

func add_scenery(obj, pos):
	obj.set_pos(map_to_world_center(pos))# + Vector2(0, -8))
	scenery.append(obj)
	get_node("OnTop").add_child(obj)

func clear_scenery():
	for obj in scenery:
		obj.queue_free()
	
	scenery = []

func get_connected_range_cells(start_pos, position_array, cell_range):
	var results = []
	
	for pos in position_array:
		if pos != start_pos and objects.has(pos):
			continue
		
		var range_array = map.get_range_cells(pos, cell_range)
		for result_pos in range_array:
			if results.has(result_pos) or position_array.has(result_pos):
				continue
			
			results.append(result_pos)
	
	return results

func map_to_world_center(pos):
	return map_to_world(pos) + get_cell_size() * 0.5

func map_to_world(pos, ignore_half_ofs = false):
	return .map_to_world(pos, ignore_half_ofs) + floor_offset

func world_to_map(pos):
	return .world_to_map(pos - floor_offset)

func can_pass(start_cell, next_cell):
	if objects.has(start_cell.pos):
		var obj = objects[start_cell.pos]
		
		if objects.has(next_cell.pos):
			var next_obj = objects[next_cell.pos]
			if obj.team != next_obj.team:
				return false
		
		if not obj.aspects & obj.aspect.FLYING and not next_cell.is_walkable:
			return false
	
	return true

func connected_cost(start_cell, next_cell):
	if objects.has(start_cell.pos):
		var obj = objects[start_cell.pos]
		
		if not obj.aspects & obj.aspect.FLYING and next_cell.type == map.TILE_FOREST:
			return 2
	
	return 1
