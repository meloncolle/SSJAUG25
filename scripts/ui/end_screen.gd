extends ColorRect

func show_results(final_time: float):
	var min := floorf(final_time / 60.0)
	var sec := final_time - (min * 60.0)
	
	var txt = """[font_size=60]%02d[/font_size] mins
[font_size=60]%f[/font_size] seconds"""
	$FinalTime.text = txt % [min, sec]
	show()
