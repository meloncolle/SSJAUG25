extends Node3D

@export var target : Node3D
@export var target_radius := 1.0

@export var camera : Node3D

var last_target_pos := Vector3.ZERO

@export var idle_thresh := 0.1
@export var max_vel:= 5.0
@export var min_y_vel := -0.15

@export var locomotion_mult_range := Vector2.ONE
#@export var velocity_tilt_amt := 10.0

## state variables
@export var skip_start_sequence := false
@export var eject := false

@export var eject_range := 5.0

# debug stuff, remove later
@export var use_overrides := false
@export var override_velocity_vector := Vector3.FORWARD
@export var override_velocity_length := 1.0

@onready var animation_tree := $AnimationTree
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

@export var dust_object : Node3D
var dust_particles : CPUParticles3D

var particle_position := Vector3.ZERO
var ground_normal := Vector3.UP

@export var dust_thresh := 0.5

var cur_vel := 0.0
var last_vel := 0.0
var vel_dir := Vector3.ZERO
var y_vel := 0.0

var spin_dist_travelled := 0.0
var last_rotated_position := Vector3.ZERO

var intro_complete := false
signal intro_completed

func _ready():
	last_target_pos = target.global_position
	if dust_object : dust_particles = dust_object.get_child(0)
	dust_particles.emitting = false

func _process(delta):
	if eject && !intro_complete:
		DoStartSequence()
	
	if intro_complete || skip_start_sequence: 
		HandleGameplayAnimation(delta)
		
	#if Input.is_action_just_pressed("ui_right"):
		#PlayFinishAnimation(true)
	#if Input.is_action_just_pressed("ui_left"):
		#PlayFinishAnimation(false)

func DoStartSequence():
	eject = false
	var start_pos = global_position
	
	var random_offset = Vector3(
			randf_range(-eject_range, eject_range),
			0.0,
			randf_range(-eject_range, eject_range))
	var land_position = global_position + random_offset
	look_at(global_position - random_offset, Vector3.UP)
	
	animation_tree.set("parameters/conditions/eject", true)
	
	var timer = 1.0
	while timer > 0.0:
		land_position.y = target.global_position.y - target_radius
		global_position = lerp(start_pos, land_position, clamp(1.0 - timer, 0.0, 1.0))
		
		timer -= 0.0166667
		await get_tree().physics_frame
	
	var current_node = ""
	while current_node != "jump":
		current_node = state_machine.get_current_node()
		await get_tree().process_frame
	
	start_pos = global_position
	var state_time = state_machine.get_current_length()
	timer = state_time
	
	while current_node == "jump":
		global_position = lerp(start_pos, GetModelOffset(Vector3.UP), 1.0 - (timer / state_time))
		
		var look_dir = start_pos - target.global_position #start_dir.slerp(start_pos - target.global_position, 1.0 - (timer / state_time))
		look_at(global_position + look_dir, Vector3.UP)
		
		current_node = state_machine.get_current_node()
		timer -= 0.0166667
		await get_tree().physics_frame
	
	intro_complete = true
	emit_signal("intro_completed")

func HandleGameplayAnimation(delta):
	var pos_d = target.global_position - last_target_pos
	
	y_vel = pos_d.y
	pos_d = ProjectV3(pos_d, ground_normal)
	
	cur_vel = pos_d.length() / delta
	vel_dir = -pos_d.normalized() if cur_vel > idle_thresh else Vector3.ZERO
	
	var acceleration = abs(cur_vel - last_vel)
	
	last_vel = cur_vel
	last_target_pos = target.global_position
	
	if use_overrides:
		cur_vel = override_velocity_length
		vel_dir = override_velocity_vector
	
	var anim_playback_speed = lerp(locomotion_mult_range.x, locomotion_mult_range.y, cur_vel / max_vel)
	animation_tree.set("parameters/locomotion/locomotion_amt/blend_position", cur_vel / max_vel)
	animation_tree.set("parameters/locomotion/locomotion_speed/scale", anim_playback_speed)
	
	if cur_vel < max_vel: # rotate model to look at velocity direction
		spin_dist_travelled = 0.0
		var start_up = global_basis.y.normalized()
		var up_vec = Vector3.UP if !camera else camera.global_basis.y #+ ((-FlattenV3(vel_dir) * cur_vel) * velocity_tilt_amt)
		up_vec = up_vec.normalized()
		if start_up.dot(up_vec) < 0.95:
			up_vec = start_up.slerp(up_vec, 10.0 * delta)
		var offset_position = GetModelOffset(up_vec) #target.global_position + (up_vec * target_radius)
		global_position = offset_position
		var default_look_dir = -global_basis.z if !camera else camera.basis.z
		default_look_dir.y = 0.0
		var look_dir = default_look_dir if cur_vel < idle_thresh else FlattenV3(vel_dir)
		look_at(global_position + look_dir, up_vec)

	else: #make model spin
		var rotation_axis = vel_dir.cross(Vector3.UP)
		var rotation_amount = spin_dist_travelled / target_radius
		var rotated_position = Vector3.UP.rotated(rotation_axis.normalized(), rotation_amount) * target_radius
		
		var look_dir = -global_basis.z
		if last_rotated_position != rotated_position && last_rotated_position != Vector3.ZERO:
			look_dir = rotated_position - last_rotated_position
		
		global_position = GetModelOffset(rotated_position) #target.global_position + rotated_position
		look_at(global_position - look_dir, rotated_position.normalized())
		
		#var spin_d = cur_vel if particle_position != Vector3.ZERO else FlattenV3(pos_d / delta).length()	
		spin_dist_travelled += cur_vel * delta
		last_rotated_position = rotated_position
		
	particle_position = GetParticlePosition()
	if acceleration > dust_thresh && dust_particles && particle_position!= Vector3.ZERO:
		dust_object.global_position = particle_position
		# KYE PUT SKID SOUND HERE (BUT CHECK W/ ELIJAH CUZ I'M NOT 100%)
		dust_particles.emitting = true
	elif acceleration <= dust_thresh && dust_particles:
		dust_particles.emitting = false

func GetModelOffset(up_vector := Vector3.UP) -> Vector3:
	
	var space_state = get_world_3d().direct_space_state
	
	var origin = target.global_position + up_vector * (target_radius * 2.0)
	var end = target.global_position
	var mask = 1<<7
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)

	var result = space_state.intersect_ray(query)
	
	if !result.is_empty():
		return result["position"]
	
	return target.global_position + (up_vector.normalized() * target_radius)

func GetParticlePosition() -> Vector3:
	
	var space_state = get_world_3d().direct_space_state
	
	var origin = target.global_position
	var end = target.global_position - (Vector3.UP * (target_radius + 0.15))
	var mask = 1
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)

	var result = space_state.intersect_ray(query)
	
	ground_normal = Vector3.UP
	
	if !result.is_empty():
		ground_normal = result["normal"]
		return result["position"]
	
	return Vector3.ZERO

func FlattenV3(vec : Vector3) -> Vector3:
	vec.y = 0.0
	return vec.normalized()

func ProjectV3(vec, normal) -> Vector3:
	return vec - (normal * normal.dot(vec))

func PlayFinishAnimation(has_won : bool):
	if has_won:
		state_machine.travel("win-start")
	else:
		state_machine.travel("lose-start")
