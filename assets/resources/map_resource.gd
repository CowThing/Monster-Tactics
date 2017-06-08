extends Resource

export var name = ""
export var tiles = {}
export var units = {}

const rect = Rect2(0, 0, 8, 8)

func set_tile(pos, value):
	if rect.has_point(pos):
		tiles[pos] = value
		return true
	
	return false

func get_tile(pos):
	if tiles.has(pos):
		return tiles[pos]
	
	return -1

func set_team_pos(pos, team):
	if rect.has_point(pos):
		units[pos] = team
		return true
	
	return false

func get_team_pos(pos):
	if units.has(pos):
		return units[pos]
	
	return -1

func erase_team_pos(pos):
	units.erase(pos)
