extends RigidBody3D
@export var speed_limit:= 15.0

func _integrate_forces(_state):
	if linear_velocity.length() > speed_limit:
		linear_velocity = linear_velocity.normalized() * speed_limit
