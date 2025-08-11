extends Node3D
class_name DeformableMesh

@export var mesh_instance : MeshInstance3D

@export var accumulate_damage := true

var debug_squish_object : Node3D

@export var wrinkle_amt := 1.0
@export var wrinkle_frequency := 2.0

var debug_squish_faloff := 1.0
var debug_squish_str := 1.0

@export var debug_rb : RigidBody3D

var original_mesh
# Called when the node enters the scene tree for the first time.
func _ready():
	original_mesh = mesh_instance.mesh.duplicate()

func DebugDoDeform():
	if !debug_squish_object : return
	var squish_dir = debug_squish_object.global_position.direction_to(global_position)
	SquashAtPoint(debug_squish_object.global_position, squish_dir, debug_squish_faloff, debug_squish_str)

func SquashAtPoint(point : Vector3, direction : Vector3, size : float, amt:= .5):
	var mesh : ArrayMesh
	if accumulate_damage:
		mesh = mesh_instance.mesh
	else:
		mesh = original_mesh.duplicate()
	
	var mdt = MeshDataTool.new()
	print(mdt.create_from_surface(mesh, 0))
	
	var local_point = to_local(point)#(point - global_position) * global_basis.inverse()
	
	var local_direction = direction * global_basis.inverse()
	var sqr_dist = size * size
	
	for i in mdt.get_vertex_count():
		var vertex = mdt.get_vertex(i)
		
		var original_pos = vertex
		
		#calulate distance falloff
		var def_amt = vertex.distance_squared_to(local_point) / sqr_dist
		def_amt = clamp(def_amt, 0.0, 1.0)
		
		var normal = mdt.get_vertex_normal(i)
		var dot = -normal.dot(direction)
		var normal_filter = 1.0 if dot >= 0.0 else 0.0
		
		#base deformation
		vertex += local_direction * ((1.0 - def_amt) * amt * normal_filter)
		
		#wrinkle deformation
		
		#get direction to deform direction
		var projeced_pos = original_pos.dot(local_direction) * local_direction.normalized()
		var projected_dir = projeced_pos.direction_to(original_pos).normalized()
		
		var wrinkle_displacement = projected_dir * sin(def_amt * wrinkle_frequency) * wrinkle_amt
		var wrinkle_falloff = (1.0 - def_amt)
		
		vertex += wrinkle_displacement * wrinkle_falloff
		
		normal += vertex - original_pos
		normal = normal.normalized()
		
		mdt.set_vertex(i, vertex)
		mdt.set_vertex_normal(i, normal)
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	mesh_instance.mesh = mesh
	
	pass
