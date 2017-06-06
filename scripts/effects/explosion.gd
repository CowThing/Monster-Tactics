extends Sprite

func _ready():
	get_tree().get_current_scene().get_node("SFX").play("explosion", true)
