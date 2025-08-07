extends Node3D

@export var target : Node3D
@export var target_radius := 1.0

var last_target_pos := Vector3.ZERO

@export var idle_thresh := 0.1
@export var max_vel:= 5.0

@export var locomotion_mult_range := Vector2.ONE

## state variables
@export var eject := false

# debug stuff, remove later
@export var use_overrides := false
@export var override_velocity_vector := Vector3.FORWARD
@export var override_velocity_length := 1.0

@onready var animation_tree := $AnimationTree
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

var cur_vel := 0.0
var vel_dir := Vector3.ZERO

var spin_dist_travelled := 0.0
var last_rotated_position := Vector3.ZERO

var intro_complete := false

func _ready():
	last_target_pos = target.global_position


func _process(delta):
	if eject && !intro_complete:
		DoStartSequence()
	
	if intro_complete : 
		HandleGameplayAnimation(delta)

func DoStartSequence():
	eject = false
	var start_pos = global_position
	
	var random_offset = Vector3(
			randf_range(-5.0, 5.0),
			0.0,
			randf_range(-5.0, 5.0))
	var land_position = global_position + random_offset
	look_at(global_position - random_offset, Vector3.UP)
	
	animation_tree.set("parameters/conditions/eject", true)
	
	var timer = 1.0
	while timer > 0.0:
		global_position = lerp(start_pos, land_position, 1.0 - timer)
		
		timer -= 0.0166667
		await get_tree().physics_frame
	
	var current_node = ""
	while current_node != "jump":
		current_node = state_machine.get_current_node()
		await get_tree().process_frame
	
	var look_dir = land_position - target.global_position
	look_at(global_position + look_dir, Vector3.UP)
	
	timer = state_machine.get_current_length()
	while current_node != "ball_idle":
		global_position = lerp(land_position, target.global_position + (Vector3.UP * target_radius), 1.0 - timer)
		
		current_node = state_machine.get_current_node()
		timer -= 0.0166667
		await get_tree().physics_frame
	
	intro_complete = true

func HandleGameplayAnimation(delta):
	var pos_d = target.global_position - last_target_pos
	
	cur_vel = pos_d.length() / delta
	vel_dir = pos_d.normalized()
	
	if use_overrides:
		cur_vel = override_velocity_length
		vel_dir = override_velocity_vector
	
	var anim_playback_speed = lerp(locomotion_mult_range.x, locomotion_mult_range.y, cur_vel / max_vel)
	animation_tree.set("parameters/locomotion/locomotion_amt/blend_position", cur_vel / max_vel)
	animation_tree.set("parameters/locomotion/locomotion_speed/scale", anim_playback_speed)
	
	if cur_vel < max_vel: # rotate model to look at velocity direction
		spin_dist_travelled = 0.0
		var offset_position = target.global_position + (Vector3.UP * target_radius)
		global_position = offset_position
		if cur_vel >= idle_thresh : look_at(global_position + vel_dir, Vector3.UP)
	else: #make model spin
		var rotation_axis = vel_dir.cross(Vector3.UP)
		var rotation_amount = spin_dist_travelled / target_radius
		var rotated_position = Vector3.UP.rotated(rotation_axis.normalized(), rotation_amount) * target_radius
		
		var look_dir = rotated_position - last_rotated_position
		
		global_position = target.global_position + rotated_position
		look_at(global_position - look_dir, rotated_position.normalized())
		
		spin_dist_travelled += cur_vel * delta
		last_rotated_position = rotated_position
