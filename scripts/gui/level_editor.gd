extends Control

# Add undo
# Add special tools like flood fill, line.

enum paint_modes {PAINT_TILES, PAINT_UNITS}

var current_paint_mode = PAINT_TILES
var target_pos = Vector2()
var selected_tile = 0

var tileset = preload("res://tilesets/tile_editor.tres")
var unitset = preload("res://tilesets/tile_teams.tres")

var current_map
var teams_pos = [[],[]]

var history = preload("res://scripts/gui/level_editor_history.gd").new()
var can_add_history = false

onready var field = get_node("PanelContainer/MapPanel/Viewport/Field")
onready var highlight = get_node("PanelContainer/MapPanel/Viewport/Highlight")
onready var team_draw = get_node("PanelContainer/MapPanel/Viewport/TeamDraw")
onready var position_label = get_node("PanelContainer/MapPanel/PositionLabel")
onready var palette = get_node("TabContainer/Palette")
onready var unit_palette = get_node("TabContainer/Teams")
onready var file_dialog = get_node("FileDialog")
onready var map_name = get_node("MapName")

var call_ready_once = false
func _ready():
	if call_ready_once:
		return
	call_ready_once = true
	
	set_process_input(true)
	Globals.set("testing_mode", true)
	
	file_dialog.set_current_dir("user://maps")
	
	# Add buttons for the palettes
	palette.set_max_columns(4)
	for id in tileset.get_tiles_ids():
		var name = tileset.tile_get_name(id)
		var tex = tileset.tile_get_texture(id)
		var region = tileset.tile_get_region(id)
		
		palette.add_icon_item(tex)
		palette.set_item_tooltip(palette.get_item_count() - 1, name)
		palette.set_item_icon_region(palette.get_item_count() - 1, region)
	palette.select(0)
	
	unit_palette.set_max_columns(4)
	for id in unitset.get_tiles_ids():
		var name = unitset.tile_get_name(id)
		var tex = unitset.tile_get_texture(id)
		var region = unitset.tile_get_region(id)
		
		unit_palette.add_icon_item(tex)
		unit_palette.set_item_tooltip(unit_palette.get_item_count() - 1, name)
		unit_palette.set_item_icon_region(unit_palette.get_item_count() - 1, region)
	unit_palette.select(0)
	
	# Initial map
	new_map()

func _enter_tree():
	music_player.play_music("menu")

func update_map():
	seed(0)
	field.build_map(current_map, false)

func update_teams():
	teams_pos = [[],[]]
	teams_pos[0].resize(4)
	teams_pos[1].resize(4)
	
	for pos in current_map.units:
		var team = current_map.units[pos]
		teams_pos[team].push_back(pos)
		teams_pos[team].pop_front()
	
	team_draw.update()

func new_map():
	current_map = load("res://assets/resources/map_resource.gd").new()
	for x in range(current_map.rect.size.width):
		for y in range(current_map.rect.size.height):
			current_map.set_tile(Vector2(x, y), 2)
	
	map_name.set_text("")
	update_teams()
	update_map()
	
	history.clear_history()
	history.add_history(current_map)

func set_current_map(new_map):
	current_map = new_map.duplicate()
	map_name.set_text(current_map.name)
	update_teams()
	update_map()

func paint_tile(pos, type):
	if not current_map.rect.has_point(pos):
		return
	
	if current_map.get_tile(pos) != type:
		can_add_history = true
		current_map.set_tile(pos, type)
		update_map()

func paint_unit(pos, team):
	if not current_map.rect.has_point(pos):
		return
	can_add_history = true
	
	_erase_unit(pos)
	
	teams_pos[team].push_back(pos)
	
	current_map.erase_team_pos(teams_pos[team].front())
	teams_pos[team].pop_front()
	
	current_map.set_team_pos(pos, team)
	team_draw.update()

func _erase_unit(pos):
	for team in teams_pos:
		if team.has(pos):
			team.erase(pos)
			team.push_front(null)
	
	current_map.erase_team_pos(pos)

func erase_unit(pos):
	if not current_map.rect.has_point(pos):
		return
	can_add_history = true
	
	_erase_unit(pos)
	team_draw.update()

func _input(event):
	if event.is_action_pressed("ui_undo"):
		_on_UndoButton_pressed()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_redo"):
		_on_RedoButton_pressed()
		get_tree().set_input_as_handled()

func _on_MapPanel_input_event( ev ):
	if ev.type == InputEvent.MOUSE_BUTTON:
		if ev.pressed:
			can_add_history = false
			if current_paint_mode == PAINT_TILES:
				if ev.button_index == BUTTON_LEFT:
					paint_tile(target_pos, selected_tile)
				else:
					paint_tile(target_pos, 2)
				
			elif current_paint_mode == PAINT_UNITS:
				if ev.button_index == BUTTON_LEFT:
					paint_unit(target_pos, selected_tile)
				else:
					erase_unit(target_pos)
			
		else:
			if can_add_history:
				history.add_history(current_map)
	
	if ev.type == InputEvent.MOUSE_MOTION:
		var new_target_pos = field.world_to_map(field.get_viewport_transform().xform_inv(ev.pos))
		if new_target_pos != target_pos:
			target_pos = new_target_pos
		
			position_label.set_text("Position: %s" % target_pos)
			position_label.set_hidden(not field.map.rect.has_point(target_pos))
			
			highlight.highlight_pos = target_pos if field.map.rect.has_point(target_pos) else null
			highlight.update()
			
			if current_paint_mode == PAINT_TILES:
				if Input.is_mouse_button_pressed(BUTTON_LEFT):
					paint_tile(target_pos, selected_tile)
				elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
					paint_tile(target_pos, 2)
				
			elif current_paint_mode == PAINT_UNITS:
				if Input.is_mouse_button_pressed(BUTTON_LEFT):
					paint_unit(target_pos, selected_tile)
				elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
					erase_unit(target_pos)

func _on_TabContainer_tab_selected( tab ):
	current_paint_mode = tab
	selected_tile = get_node("TabContainer").get_tab_control(tab).get_selected_items()[0]

func _on_Palette_item_selected( index ):
	selected_tile = index

func _on_Teams_item_selected( index ):
	selected_tile = index

func _on_FileDialog_file_selected( path ):
	if file_dialog.get_mode() == FileDialog.MODE_SAVE_FILE:
		ResourceSaver.save(path, current_map)
	elif file_dialog.get_mode() == FileDialog.MODE_OPEN_FILE:
		var new_file = load(path)
		if new_file extends preload("res://assets/resources/map_resource.gd"):
			set_current_map(new_file)
			history.clear_history()
			history.add_history(current_map)

func _on_Save_pressed():
	file_dialog.set_mode(FileDialog.MODE_SAVE_FILE)
	file_dialog.invalidate()
	file_dialog.set_current_file(map_name.get_text())
	file_dialog.popup()

func _on_Load_pressed():
	file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	file_dialog.invalidate()
	file_dialog.popup()

func _on_OpenData_pressed():
	OS.shell_open(OS.get_data_dir())

func _on_TestButton_pressed():
	global.monster_controller = load("res://scripts/turn_states/player_turn.gd")
	global.human_controller = load("res://scripts/turn_states/cpu_turn.gd")
	global.level = current_map
	
	scene_transition.swap_scene(load("res://scenes/main.tscn"))

func _on_MapName_text_entered( text ):
	current_map.name = str(text)

func _on_NewButton_pressed():
	new_map()

func _on_BackButton_pressed():
	Globals.set("testing_mode", false)
	scene_transition.goto_scene(load("res://scenes/mainmenu.tscn"))

func _on_UndoButton_pressed():
	var ret = history.undo()
	if ret:
		set_current_map(ret)

func _on_RedoButton_pressed():
	var ret = history.redo()
	if ret:
		set_current_map(ret)
