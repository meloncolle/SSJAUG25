extends Button
class_name SoundButton

func _ready():
	connect("focus_entered", _on_focused)
	connect("pressed", _on_pressed)

# ok so this is gonna fire automatically when the menu opens once, gotta find a workaround
func _on_focused():
		# KYE PUT UINAVIGATE SOUND HERE (and delete print statement)
		$Audio/UInavigate.play()
		print("BUTTON FOCUSED")
	
func _on_pressed():
		# KYE PUT UISELECT SOUND HERE
		$Audio/UIselect.play()
		print("BUTTON PRESSED")
