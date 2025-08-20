extends Label

@onready var ms_display: Label = $Millisecond

func _on_timer_changed(new_time: float):
	var min := floorf(new_time / 60.0)
	var sec := floorf(new_time - (min * 60.0))
	var ms := (new_time - (min * 60.0) - sec) * 1000.0
	
	var fstr := "%02d:%02d"
	text = fstr % [min, sec]
	fstr = "%02d"
	ms_display.text = fstr % [snapped(ms, 10) / 10]
