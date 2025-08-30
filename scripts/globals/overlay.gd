extends ColorRect

func fade_to_black(duration: float) -> Tween:
	color = Color(Color.BLACK, 0.0)
	show()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color", Color.BLACK, duration)
	return tween
	
func fade_from_black(duration: float) -> Tween:
	color = Color.BLACK
	show()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color", Color(Color.BLACK, 0.0), duration)
	return tween
