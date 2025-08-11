extends Node3D

@export var camera : Camera3D
@export var squishable : DeformableMesh

@export var squish_size := 1.0
@export var squish_amt := 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !camera || !squishable : return
	
	if Input.is_action_just_pressed("ui_accept"):
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()

		var origin = camera.project_ray_origin(mousepos)
		var end = origin + camera.project_ray_normal(mousepos) * 100.0
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		
		if !result.is_empty():
			var squish_pos = result["position"]
			var squish_dir = -result["normal"]
			
			squishable.SquashAtPoint(squish_pos, squish_dir, squish_size, squish_amt)
			
			squishable.debug_rb.apply_impulse(Vector3(0.0, 1.0, 0.0) * 150.0)
