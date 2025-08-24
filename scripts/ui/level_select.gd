extends Control

@onready var back_button: SoundButton = $Panel/VBoxContainer/Button
var buttons: Array[SoundButton] = []

func _ready():
	var current_button: SoundButton = back_button
	# Get level_name from packedscene without instantiating...
	for i in range(SceneManager.levels.size()):
		var level: PackedScene = SceneManager.levels[i]
		var lvl_name:= ""
		var button: SoundButton
		
		var state:= level.get_state()
		var prop_count:= state.get_node_property_count(0)
		for j in range(prop_count):
			if state.get_node_property_name(0, j) == "level_name":
				lvl_name = state.get_node_property_value(0, j)
				break
		
		var new_button: SoundButton = current_button.duplicate()
		current_button.add_sibling(new_button)
		current_button = new_button
		current_button.text = lvl_name
		buttons.append(current_button)
		
	back_button.get_parent().move_child(back_button, buttons.size())
