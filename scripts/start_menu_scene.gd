extends Node3D

signal ad_finished

const skip_code: Array[Enums.CheatInput] = [
	Enums.CheatInput.UP, 
	Enums.CheatInput.DOWN,
	Enums.CheatInput.RIGHT,
	Enums.CheatInput.RIGHT,
	Enums.CheatInput.LEFT,
	Enums.CheatInput.LEFT]

var ad_played:= false
var ad_playing:= false
var inputs: Array[Enums.CheatInput] = []

@onready var racer: Node3D = $RacerBen
@onready var car: Node3D = $"car_solo[art]"
@onready var cam: Node3D = $CamRig
@onready var ad_emitter: FmodEventEmitter2D = $ben_callout

func _ready():
	ad_emitter.connect("stopped", func(): emit_signal("ad_finished"); ad_playing = false)
	
	var state_machine := racer.get_node("AnimationTree").get("parameters/playback") as AnimationNodeStateMachinePlayback
	state_machine.start("lose")

func _process(delta):
	if ad_playing:
		if Input.is_action_just_pressed("cheat_up"):
			add_input(Enums.CheatInput.UP)
		elif Input.is_action_just_pressed("cheat_right"):
			add_input(Enums.CheatInput.RIGHT)
		elif Input.is_action_just_pressed("cheat_down"):
			add_input(Enums.CheatInput.DOWN)
		elif Input.is_action_just_pressed("cheat_left"):
			add_input(Enums.CheatInput.LEFT)
	
	car.rotate_y(delta)

func play_ad():
	if ad_played: 
		emit_signal("ad_finished")
	
	else:
		ad_played = true
		ad_playing = true
		ad_emitter.play()
		$AnimationPlayer.play("play_subtitles")
		
func add_input(new_input: Enums.CheatInput):
	$keygen_type.play()
	inputs.append(new_input)
	if inputs.size() > skip_code.size():
		inputs.pop_front()
	
	if CheatLib.inputs_to_string(inputs) == CheatLib.inputs_to_string(skip_code):
		emit_signal("ad_finished")
		$code_right.play()
