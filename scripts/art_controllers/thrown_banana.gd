extends RigidBody3D

func _ready():
	# launch in a random direction and destruct after 5 secs
	var launch_vec:= Vector3(1,3,1).rotated(Vector3.UP, randf_range(0, 2 * PI))
	apply_central_impulse(launch_vec)
	
	await get_tree().create_timer(5).timeout
	#TODO: maybe a disappear anim
	queue_free()
