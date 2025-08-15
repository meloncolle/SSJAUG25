extends Node3D

@export var target : Node3D

@export var car_default : Node3D
@export var car_crushed : Node3D
@export var particles : Node3D

var p_systems : Array[CPUParticles3D]

#state vars
@export var set_tracking_on_ready := false

var is_tracking := false : 
	set(val):
		if !is_tracking && val:
			SwapModels()
		is_tracking = val

func _ready():
	if particles:
		for i in particles.get_children():
			if i is CPUParticles3D:
				p_systems.append(i)
				
	if set_tracking_on_ready: is_tracking = true

func _process(delta):
	if !is_tracking : return
	
	global_transform = target.global_transform

func SwapModels():
	if car_default : car_default.visible = false
	if car_crushed : car_crushed.visible = true
	
	for i in p_systems:
		i.emitting = true
