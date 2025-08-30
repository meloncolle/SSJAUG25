extends Node

# DEVELOPER DEBUG THINGS (don't commit if you change these)

# Lets you skip the opening/start menu and go straight to level
# Set to the index of level to skip to
# Set to -1 to ignore
const SKIP_TO_LEVEL: int = -1
const DEBUG_PANEL: bool = false

#----------------------------------------------

const SAVE_PATH: String = "user://settings.cfg"
const DEFAULTS = {
	"cam_sensitivity": 0.05,
}

var data = ConfigFile.new()

func _init():
	var err = data.load(SAVE_PATH)

	# If the file didn't load, set defaults and save
	if err != OK:
		for k in DEFAULTS.keys():
			data.set_value("settings", k, DEFAULTS[k])
			
		data.save(SAVE_PATH)
