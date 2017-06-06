extends Node2D

var PlayerTurnClass = preload("res://scripts/turn_states/player_turn.gd")

var round_over = false

onready var field = get_node("Field")
onready var turn_controller = preload("res://scripts/turn_controller.gd").new(self)
onready var hud = get_node("HUD")

func _ready():
	turn_controller.connect("round_end", self, "_on_round_end")
	
	music_player.play_music("battle")
	
	call_deferred("start_game", global.monster_controller, global.human_controller, global.level)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		turn_controller.free()

func start_game(control_a, control_b, map):
	field.build_map(load(map))
	turn_controller.start_round(control_a, control_b)

func _on_round_end(winner):
	round_over = true
	
	if (global.monster_controller == global.human_controller)\
	or turn_controller.teams[winner] extends PlayerTurnClass:
		music_player.play_music("fanfare2", false)
		yield(music_player, "finished")
	
	music_player.play_music("menu")
