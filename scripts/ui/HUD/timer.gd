extends Label

@onready var ms_display: Label = $Millisecond

func _on_timer_changed(new_time: float):
	var mins := floorf(new_time / 60.0)
	var sex := floorf(new_time - (mins * 60.0))
	var ms := (new_time - (mins * 60.0) - sex) * 1000.0
	
	var fstr := "%02d:%02d"
	text = fstr % [mins, sex]
	fstr = "%02d"
	ms_display.text = fstr % [snapped(ms, 10) / 10]
