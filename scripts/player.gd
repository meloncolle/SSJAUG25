extends RigidBody3D
@export var max_speed:= 15.0:
	set(value):
		max_speed = value
		emit_signal("max_speed_changed", max_speed)

signal max_speed_changed

var awaiting_respawn:= false
var respawn_target: Node3D = null

func respawn(target: Node3D):
	respawn_target = target
	awaiting_respawn = true

func _integrate_forces(_state):
	if awaiting_respawn && respawn_target != null:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		global_position = respawn_target.global_position
		awaiting_respawn = false
		respawn_target = null
	
	else:
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed
