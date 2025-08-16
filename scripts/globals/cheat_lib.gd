extends Node

@export var codes: Array[CheatCode]

func _ready():
	print("bubba")
	# We want to make sure no codes in library have inputs as subsequences of other codes
	# We could comment this out and just check manually bc its kind of wasteful >_>
	var c_string: String
	var d_string: String
	for c in codes:
		c_string = inputs_to_string(c.sequence)
		for d in codes:
			if c == d: continue
			d_string = inputs_to_string(d.sequence)
			assert(!c_string.is_subsequence_of(d_string), "Cheat '%s' inputs are subsequence of cheat '%s'" % [c.name, d.name])

# Check if any cheat code sequence is found in input
# If match found, return CheatCode resource
# If none found, return null
func find_match(input: Array[Enums.CheatInput]) -> CheatCode:
	var input_string := inputs_to_string(input)
	var code_string: String
	for c in codes:
		code_string = inputs_to_string(c.sequence)
		if code_string.is_subsequence_of(input_string):
			return c
	return null

# Convert CheatInput sequence to string of numbers, so we can easily use subsequence func
func inputs_to_string(input: Array[Enums.CheatInput]) -> String:
	var result := ""
	for i in input:
		result += str(i)
	return result
