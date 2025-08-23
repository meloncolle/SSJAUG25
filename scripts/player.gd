extends RigidBody3D
class_name Player

signal finished_respawn

@onready var car: Node3D = $"Car/car_scuffed[art]"
@onready var col_shape: CollisionShape3D = $CollisionShape3D

@export var max_speed:= 15.0:
	set(value):
		max_speed = value
		emit_signal("max_speed_changed", max_speed)

signal changed_size

var size:
	set(value):
		size = value % 3
		print("size: %d" % size)
		match size:
			0:
				# tinymode
				col_shape.shape.radius = 0.25
				car.scale = Vector3.ONE * 0.25
			1:
				# default
				col_shape.shape.radius = 0.5
				car.scale = Vector3.ONE * 0.5
			2:
				# bigmode
				col_shape.shape.radius = 0.75
				car.scale = Vector3.ONE * 0.75
				
signal max_speed_changed

var awaiting_respawn:= false
var respawn_target: Node3D = null

func _ready():
	size = 1

func respawn():
	# KYE PUT RESPAWN SOUND HERE
	size = 1
	awaiting_respawn = true

func _integrate_forces(_state):
	if awaiting_respawn && respawn_target != null:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		global_position = respawn_target.global_position
		global_rotation = respawn_target.global_rotation
		awaiting_respawn = false
		emit_signal("finished_respawn")
	
	else:
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed
