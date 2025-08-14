# note gamestate is still PAUSED while in settings menu
extends Control

signal settings_closed(Dictionary) # return config settings dict, or {} if settings cancelled

@onready var confirm_button: Button = $Panel/VBoxContainer/ConfirmButton
@onready var cancel_button: Button = $Panel/VBoxContainer/CancelButton

func _ready():
	# todo: read settings from config, or set default if doesn't exist
	
	confirm_button.pressed.connect(self._on_press_confirm)
	cancel_button.pressed.connect(self._on_press_cancel)

func _input (event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		# don't want it to propagate and close pause menu
		# if this causes problems later, can always add another gamestate for settings
		get_viewport().set_input_as_handled()

# Return dictionary of settings based on menu config
func get_settings() -> Dictionary:
	# TODO
	return {"settings": true}
	
func _on_press_confirm():
	emit_signal("settings_closed", get_settings())
	# todo: revert controls to whatever's in config
	
func _on_press_cancel():
	emit_signal("settings_closed", {})
