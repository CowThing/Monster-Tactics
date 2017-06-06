extends Node

func _ready():
	music_player.play_music("menu")
	get_node("Field").build_map(preload("res://scenes/levels/level0.tscn"), false)
	get_node("Menu/SettingsPopup/VBoxContainer/MusicSlider").set_value(AS.get_stream_global_volume_scale() * 10)
	get_node("Menu/SettingsPopup/VBoxContainer/SoundSlider").set_value(AS.get_fx_global_volume_scale() * 10)

func _on_StartButton_pressed():
	get_node("SFX").play("button")
	scene_transition.goto_scene(preload("res://scenes/game_select.tscn"))

func _on_QuitButton_pressed():
	get_node("SFX").play("button")
	get_tree().quit()

func _on_MusicSlider_value_changed( value ):
	AS.set_stream_global_volume_scale(value * 0.1)

func _on_SoundSlider_value_changed( value ):
	AS.set_fx_global_volume_scale(value * 0.1)

func _on_HowToButton_pressed():
	get_node("SFX").play("button")
	get_node("Menu/HowToPopup").popup()

func _on_SettingsButton_pressed():
	get_node("SFX").play("button")
	get_node("Menu/SettingsPopup").popup()
