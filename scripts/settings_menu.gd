# note gamestate is still PAUSED while in settings menu
extends Control

signal settings_closed
signal settings_changed

@onready var confirm_button: Button = $Panel/VBoxContainer/ConfirmButton
@onready var cancel_button: Button = $Panel/VBoxContainer/CancelButton

@onready var cam_sensitivity: HSlider = $Settings/CamSensitivity/HSlider

func _ready():
	sync_ui()	
	confirm_button.pressed.connect(self._on_press_confirm)
	cancel_button.pressed.connect(self._on_press_cancel)

func _input (event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		# Disable closing settings menu with esc, because we dont know if you wanna save settings or not
		
		# don't want it to propagate and close pause menu
		# if this causes problems later, can always add another gamestate for settings
		if visible:
			get_viewport().set_input_as_handled()

# Return dictionary of settings based on menu config
func get_settings() -> ConfigFile:
	var settings = ConfigFile.new()
	
	# add to this for each addtl setting
	settings.set_value("settings", "cam_sensitivity", cam_sensitivity.value)
	
	return settings
	
func _on_press_confirm():
	var new_config := get_settings()
	if new_config != Config.data:
		Config.data = new_config
		Config.data.save(Config.SAVE_PATH)
		emit_signal("settings_changed")
	emit_signal("settings_closed")
	
func _on_press_cancel():
	emit_signal("settings_closed")
	sync_ui()

# Read from config and update controls to match
func sync_ui():
	# add to this for each addtl setting
	cam_sensitivity.value = Config.data.get_value("settings", "cam_sensitivity", Config.DEFAULTS["cam_sensitivity"])
	
