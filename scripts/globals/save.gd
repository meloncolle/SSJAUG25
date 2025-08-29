extends Node

const SAVE_PATH: String = "user://data.save"
const MAX_SCORES_PER_LEVEL = 10
var data = ConfigFile.new()

func _init() -> void:
	# Load data from a file.
	var _err = data.load(SAVE_PATH)

#return -1 if not high score, return placement if it was a high score
func add_new_score(level_name: String, new_score: float) -> int:
	var scores: Array = data.get_value("Scores", level_name, [])
	
	if (scores.size() < MAX_SCORES_PER_LEVEL || 
		scores.any(func(e): return e > new_score)):

		scores.append(new_score)
		scores.sort()
		
		if scores.size() > MAX_SCORES_PER_LEVEL:
			scores = scores.slice(0, MAX_SCORES_PER_LEVEL)
			
		data.set_value("Scores", level_name, scores)
		data.save(SAVE_PATH)
		
	return scores.find(new_score)
