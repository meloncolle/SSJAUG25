extends Window

const MAX_INPUTS: int = 8

@export var tries: int = 3

signal code_accepted(code: CheatCode)
signal code_rejected

var input_enabled := false
var reopen_on_resume := false

var inputs: Array[Enums.CheatInput] = []
@onready var arrow_icons:= $Input/Arrows.get_children()
@onready var input_field: ColorRect = $Input
@onready var error_msg: Label = $Input/ErrorLabel

func _ready():
	connect("close_requested", _on_close_requested)
	
func _input(event):
	if event.is_action_pressed("toggle_console"):
		emit_signal("close_requested")
	
	# this is soo stupid but theres some weird issue where pause event isnt propagated
	# when keygen window is open BUT only when pausing with keyboard. 
	# i.e. u can only pause when it's open w/ controller
	# handling it here but we should really test it on other platforms
	elif event.is_action_pressed("pause"):
		reopen_on_resume = visible
		hide()
		
		if SceneManager.game_state == Enums.GameState.IN_GAME:
			# pause failed so we must have used keyboard. need to manually pause from scenemanager
			SceneManager.set_state(Enums.GameState.PAUSED)
	
	elif input_enabled:
		if event.is_action_pressed("cheat_up"):
			add_input(Enums.CheatInput.UP)
		elif event.is_action_pressed("cheat_right"):
			add_input(Enums.CheatInput.RIGHT)
		elif event.is_action_pressed("cheat_down"):
			add_input(Enums.CheatInput.DOWN)
		elif event.is_action_pressed("cheat_left"):
			add_input(Enums.CheatInput.LEFT)
		
func _on_close_requested():
	hide()

func _on_open_requested():
	inputs = []
	input_enabled = true
	error_msg.hide()
	input_field.color = Color.WHITE
	for i in arrow_icons: 
		i.hide()
		i.modulate = Color(Color.WHITE, 1.0)
	show()
		
func add_input(input: Enums.CheatInput):
	inputs.append(input)
	
	arrow_icons[inputs.size() -1 ].rotation = 0.5 * PI * input
	arrow_icons[inputs.size() -1 ].show()
	
	# Check if current input sequence contains any valid cheat code
	var result = CheatLib.find_match(inputs)
	if result[0] != null:
		input_field.color = Color.LIGHT_GREEN
		for i in range(result[1]):
			arrow_icons[i].modulate = Color(Color.WHITE, 0.25)
		await get_tree().create_timer(0.75).timeout
		emit_signal("code_accepted", result[0])
		emit_signal("close_requested")

	if inputs.size() >= MAX_INPUTS:
		input_enabled = false
		for i in arrow_icons: i.hide()
		error_msg.show()
		input_field.color = Color.RED
		await get_tree().create_timer(0.75).timeout
		emit_signal("code_rejected")
		emit_signal("close_requested")
