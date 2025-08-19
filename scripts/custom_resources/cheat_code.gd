extends Resource
class_name CheatCode

@export var name: String
@export var sequence: Array[Enums.CheatInput]
@export var description: String
@export var duration := 0.0 # If 0, lasts indefinitely
@export var cooldown := 0.0 # If 0, no cooldown
var times_used := 0 # This session only. TODO: Find way to store if unlocked, persistently

func get_string() -> String:
	return """Name: %s
	Description: %s
	Inputs: %s
	Used: %d time(s)""" % [name, description, CheatLib.inputs_to_string(sequence), times_used]
