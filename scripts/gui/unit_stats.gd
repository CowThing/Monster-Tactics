extends Panel

var hover_unit = WeakRef.new() setget set_hover_unit, get_hover_unit
var locked_unit = WeakRef.new() setget set_locked_unit, get_locked_unit

func _ready():
	set_process_input(true)

func set_hover_unit(new):
	if new == null:
		hover_unit = WeakRef.new()
		return
	
	hover_unit = weakref(new)

func get_hover_unit():
	return hover_unit.get_ref()

func set_locked_unit(new):
	if new == null:
		locked_unit = WeakRef.new()
		return
	
	get_tree().get_current_scene().get_node("SFX").play("unit_select")
	locked_unit = weakref(new)

func get_locked_unit():
	return locked_unit.get_ref()

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var normalized_pos = get_parent().get_parent().get_viewport_transform().xform_inv(event.pos)
		var new_unit = get_parent().field.get_object(normalized_pos)
		if new_unit != self.hover_unit and self.locked_unit == null:
			self.hover_unit = new_unit
			update_hover_unit()

func update_hover_unit():
	if self.hover_unit == null or (self.hover_unit and self.hover_unit.team == -1):
		get_parent().field.get_node("Draw").hover_pos = null
		get_node("HoverUnitPanel").set_unit(null)
		return
	
	get_parent().field.get_node("Draw").hover_pos = self.hover_unit.map_pos
	get_node("HoverUnitPanel").set_unit(self.hover_unit)

func _on_selected_object_changed(new_obj):
	get_node("UnitPanel").set_unit(new_obj)
	update_hover_unit()

func _on_lock_hover(pos):
	var new_object = null
	if get_parent().field.objects.has(pos)\
	and get_parent().field.objects[pos].team != -1\
	and get_parent().field.objects[pos] != self.locked_unit:
		new_object = get_parent().field.objects[pos]
	
	self.locked_unit = new_object
	self.hover_unit = self.locked_unit
	update_hover_unit()

func _on_turn_end():
	self.locked_unit = null
	self.hover_unit = null
	update_hover_unit()
