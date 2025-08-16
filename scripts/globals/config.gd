extends Node

const SAVE_PATH: String = "user://settings.cfg"
const DEFAULTS = {
	"cam_sensitivity": 0.05,
}

var data = ConfigFile.new()

func _init():
	var err = data.load(SAVE_PATH)

	# If the file didn't load, set defaults and save
	if err != OK:
		print("file didnt load")
		for k in DEFAULTS.keys():
			data.set_value("settings", k, DEFAULTS[k])
			
		data.save(SAVE_PATH)
