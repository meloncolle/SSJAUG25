@tool
extends Node3D

@export var original : PackedScene
@export var path_parent : Node3D
var path : Path3D

@export var instance_count := 0 : 
	set(val):
		val = clampi(val, 0, 250)
		instance_count = val
		PlaceInstances()
@export var separation := 0.5: 
	set(val):
		separation = val
		PlaceInstances()
@export var start_offset := 0.0: 
	set(val):
		start_offset = val
		PlaceInstances()
@export var offset_from_curve := Vector2.ZERO: 
	set(val):
		offset_from_curve = val
		PlaceInstances()
@export var instance_y_rotation := 0.0: 
	set(val):
		instance_y_rotation = val
		PlaceInstances()
@export var use_model_forward := false :
	set(val):
		use_model_forward = val
		PlaceInstances()
@export var use_path_up := false :
	set(val):
		use_path_up = val
		PlaceInstances()

var instances : Array[Node3D]

func PlaceInstances():
	if !Engine.is_editor_hint():
		return # shouldn't run in play mode!
	if path_parent == null:
		print_debug("No path parent assigned to instance placement tool")
		return
	
	GetPath()
	
	if path == null: 
		print_debug("No path found as child of path parent")
		return
	if original == null: 
		print_debug("No original assigned to instance placement tool")
		return
	
	GetInstanceList()
	var diff = instances.size() - instance_count
	
	if diff > 0:
		for n in abs(diff):
			var instance_to_remove = instances.pop_back()
			instance_to_remove.queue_free()
	elif diff < 0:
		for n in abs(diff):
			var new_instance = original.instantiate()
			add_child(new_instance)
			new_instance.owner = get_tree().edited_scene_root
			instances.append(new_instance)
	
	for n in instances.size():
		var curve_distance = start_offset + (separation * n)
		
		var curve_transform = path.curve.sample_baked_with_rotation(curve_distance, false, true)
		var curve_dir = curve_transform.basis.z
		var curve_normal = curve_transform.basis.y
		var curve_tangent = curve_transform.basis.x
		
		var local_position = curve_transform.origin + (curve_tangent * offset_from_curve.x) + (curve_normal * offset_from_curve.y)
		var flat_curve_dir = curve_dir
		flat_curve_dir.y = 0.0
		flat_curve_dir = flat_curve_dir.normalized()
		
		var up_vec = Vector3.UP if !use_path_up else curve_normal
		
		var facing_dir = flat_curve_dir.rotated(up_vec, deg_to_rad(instance_y_rotation))
		instances[n].position = local_position
		instances[n].look_at(local_position + facing_dir, up_vec, use_model_forward)

func GetPath():
	path = null
	for n in path_parent.get_children():
		if n is Path3D : 
			path = n
			return
			
func GetInstanceList():
	instances.clear()
	var instance_list = get_children() 
	for n in instance_list:
		if n is Node3D:
			instances.append(n)
