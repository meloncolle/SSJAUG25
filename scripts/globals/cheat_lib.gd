extends Node

@export var codes: Array[CheatCode]
var active_codes:= {}
signal active_codes_changed

func _ready():
	# We want to make sure no codes in library have inputs as subsets of other codes
	# We could comment this out and just check manually bc its kind of wasteful >_>
	var c_string: String
	var d_string: String
	for c in codes:
		c_string = inputs_to_string(c.sequence)
		for d in codes:
			if c == d: continue
			d_string = inputs_to_string(d.sequence)
			assert(c_string not in (d_string), "Cheat '%s' inputs are subsequence of cheat '%s'" % [c.name, d.name])
	
	# Initialize all codes to inactive		
	for c in codes:
		active_codes[c.name] = false

func set_active(cheat_name: String, is_active:= true):
	active_codes[cheat_name] = is_active
	emit_signal("active_codes_changed")
	
func get_only_active() -> Array[String]:
	var only_active: Array[String] = []
	for key in active_codes.keys():  
		if active_codes[key] == true: only_active.append(key)
	return only_active

# Check if any cheat code sequence is found in input
# If match found, return CheatCode resource and index in the input string it starts at
# If none found, return [null, -1]
func find_match(input: Array[Enums.CheatInput]) -> Array:
	var input_string := inputs_to_string(input)
	var code_string: String
	var index: int
	for c in codes:
		code_string = inputs_to_string(c.sequence)
		index = input_string.find(code_string)
		if index != -1:
			return [c, index]
	return [null, -1]

# Convert CheatInput sequence to string of numbers, so we can easily check subset
func inputs_to_string(input: Array[Enums.CheatInput]) -> String:
	var result := ""
	for i in input:
		result += str(i)
	return result
