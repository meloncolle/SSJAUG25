extends ColorRect

func show_results(final_time: float):
	var mins := floorf(final_time / 60.0)
	var sex := final_time - (mins * 60.0)
	
	var txt = """[font_size=60]%02d[/font_size] mins
[font_size=60]%f[/font_size] seconds"""
	$FinalTime.text = txt % [mins, sex]
	show()
