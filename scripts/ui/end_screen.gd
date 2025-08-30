extends ColorRect

@onready var score_list: VBoxContainer = $ScoreList

func show_results(final_time: float, level_name: String):
	var new_hi_score: int = Save.add_new_score(level_name, final_time)

	var formatted_time:= format_time(final_time)
	%FinalTime.text = formatted_time[0]
	%FinalTime.get_node("Millisecond").text = formatted_time[1]
	$AnimationPlayer.play("RESET")
	show()
	$AnimationPlayer.play("show")
	
	var entries: Array[RichTextLabel] = []
	entries.append(score_list.get_node("Score"))
	
	var new_rich_text: RichTextLabel
	
	for i in range(Save.MAX_SCORES_PER_LEVEL - 1):
		new_rich_text = entries[0].duplicate()
		new_rich_text.get_child(0).text = "%d." % (i + 2)
		entries.append(new_rich_text)
		score_list.add_child(new_rich_text)
		
	var hi_scores = Save.data.get_value("Scores", level_name, [])
	
	for i in range(hi_scores.size()):
		var formatted_score:= format_time(hi_scores[i])
		var entry_txt:= "%s .%s" % [formatted_score[0], formatted_score[1]]
		if i == new_hi_score:
			entry_txt = "[color=green]%s[/color]" % entry_txt
		entries[i].text = entry_txt
	
func format_time(final_time: float) -> Array[String]:
	var mins := floorf(final_time / 60.0)
	var sex := floorf(final_time - (mins * 60.0))
	var ms := (final_time - (mins * 60.0) - sex) * 1000.0

	return [("%02d:%02d" % [mins, sex]), ("%02d" % [snapped(ms, 10) / 10])]
