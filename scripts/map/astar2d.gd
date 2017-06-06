extends AStar

var map
var start_cell

func _init(map):
	self.map = map

func cost(from_id, to_id):
	# This doesn't always work 100%
	if not self.map.field.can_pass(start_cell, self.map.get_cell_id(from_id)):
		return 100000
	
	return get_point_pos(from_id).distance_to(get_point_pos(to_id))

func _compute_cost(from_id, to_id):
	return cost(from_id, to_id)

func _estimate_cost(from_id, to_id):
	return cost(from_id, to_id)

# Vector2D functions

func add_point(id, pos, weight_scale=1):
	return .add_point(id, Vec2to3(pos), weight_scale)

func get_point_id(pos):
	return .get_closest_point(Vec2to3(pos))

func get_point_pos(id):
	return Vec3to2(.get_point_pos(id))

func get_point_path(id_start, id_end):
	start_cell = self.map.get_cell_id(id_start)
	
	var path = Array(.get_point_path(id_start, id_end))
	for p in path:
		path[path.find(p)] = Vec3to2(p)
	
	start_cell = null
	
	return Vector2Array(path)

static func Vec2to3(vec):
	return Vector3(vec.x, vec.y, 0)

static func Vec3to2(vec):
	return Vector2(vec.x, vec.y)
