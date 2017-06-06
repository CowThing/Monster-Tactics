extends CanvasLayer

var PlayerTurnClass = preload("res://scripts/turn_states/player_turn.gd")

var is_player_turn = false

var field

func _ready():
	call_deferred("post_ready")

func post_ready():
	field = get_parent().field
	get_parent().turn_controller.connect("round_start", self, "_on_round_start")
	get_parent().turn_controller.connect("round_end", self, "_on_round_end")
	get_parent().turn_controller.connect("turn_start", self, "_on_turn_start")
	get_parent().turn_controller.connect("turn_end", self, "_on_turn_end")
	get_node("Combat").connect("combat_start", self, "_on_combat_start")
	get_node("Combat").connect("combat_finished", self, "_on_combat_finished")
	
	get_parent().turn_controller.connect("turn_end", get_node("UnitStats"), "_on_turn_end")

func _on_round_start():
	for team in get_parent().turn_controller.teams:
		if team extends PlayerTurnClass:
			team.connect("selected_object_changed", self, "_on_selected_object_changed", [team])
			team.connect("selected_object_changed", get_node("UnitStats"), "_on_selected_object_changed")
			team.connect("lock_hover", get_node("UnitStats"), "_on_lock_hover")

func _on_round_end(winner):
	get_node("Panel/EndTurnButton").set_disabled(true)
	
	var team_name = "Monster" if winner == 0 else "Human"
	get_node("Panel/Message").set_text("%ss have won" % team_name)

func _on_selected_object_changed(new_obj, team):
	field.get_node("Draw").update_selected(
		team.selected_object,
		team.selected_positions,
		team.selected_attackable
	)

func _on_turn_start():
	is_player_turn = false
	if get_parent().turn_controller.teams[get_parent().turn_controller.current_team] extends PlayerTurnClass:
		is_player_turn = true
	
	get_node("Panel/EndTurnButton").set_disabled(not is_player_turn)

func _on_turn_end():
	get_node("Panel/EndTurnButton").set_disabled(true)

func _on_combat_start():
	get_node("Panel/EndTurnButton").set_disabled(true)

func _on_combat_finished():
	get_node("Panel/EndTurnButton").set_disabled(not is_player_turn)

func _on_EndTurnButton_pressed():
	if is_player_turn:
		get_parent().get_node("SFX").play("button")
		get_parent().turn_controller.teams[get_parent().turn_controller.current_team].end_turn()

func _on_MenuButton_pressed():
	get_parent().get_node("SFX").play("button")
	get_node("PopupPanel").popup_centered_ratio(0.5)
