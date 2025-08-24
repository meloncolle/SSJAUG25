extends Control

const MAX_INPUTS: int = 8

signal code_accepted(code: CheatCode)
signal code_rejected

var input_enabled := false
var reopen_on_resume := false

var inputs: Array[Enums.CheatInput] = []
@onready var arrow_icons:= $Input/Arrows.get_children()
@onready var input_field: ColorRect = $Input

func _process(_delta):
	# Moved to _process() because it gets double input in _input()
	if input_enabled:
		if Input.is_action_just_pressed("cheat_up"):
			add_input(Enums.CheatInput.UP)
		elif Input.is_action_just_pressed("cheat_right"):
			add_input(Enums.CheatInput.RIGHT)
		elif Input.is_action_just_pressed("cheat_down"):
			add_input(Enums.CheatInput.DOWN)
		elif Input.is_action_just_pressed("cheat_left"):
			add_input(Enums.CheatInput.LEFT)
		
func _on_close_requested():
	
	# KYE PUT KEYGEN CLOSE SOUND HERE
	hide()

func _on_open_requested():
	inputs = []
	input_enabled = true
	input_field.color = Color.WHITE
	for i in arrow_icons: 
		i.hide()
		i.modulate = Color(Color.WHITE, 1.0)
		
	$Audio/keygen_open.play()
	show()
		
func add_input(input: Enums.CheatInput):
	$Audio/keygen_type.play()
	# KYE PUT KEYGEN CHARACTER ENTERED SOUND HERE
	inputs.append(input)
	
	arrow_icons[inputs.size() -1 ].rotation = 0.5 * PI * input
	arrow_icons[inputs.size() -1 ].show()
	
	# Check if current input sequence contains any valid cheat code
	var result = CheatLib.find_match(inputs)
	if result[0] != null:
		$Audio/code_right.play()# KYE PUT CHEATCODERIGHT SOUND HERE
		input_enabled = false
		input_field.color = Color.LIGHT_GREEN
		for i in range(result[1]):
			arrow_icons[i].modulate = Color(Color.WHITE, 0.25)
		await get_tree().create_timer(0.25, false).timeout
		emit_signal("code_accepted", result[0])
		_on_close_requested()

	elif inputs.size() >= MAX_INPUTS:
		$Audio/code_wrong.play()# KYE PUT CHEATCODEWRONG SOUND HERE
		input_enabled = false
		input_field.color = Color.RED
		await get_tree().create_timer(0.25, false).timeout
		emit_signal("code_rejected")
		_on_close_requested()
