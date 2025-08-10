# todo: add some sort of logic to switch directions faster

# todo: probably add check to set gravity to DOWN if we fall off da track

# todo: something to make the ball "stick" to the ground better? u kind of lift off
# from tilting back/forth quickly and float around... would probably be fixed by first todo

# NOTE THE GRAVITY SCALE ON PLAYER

extends Node3D

@export var tilt_speed:= 2.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_x: float = PI / 4.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_z: float = PI / 4.0

var desired_gravity:= Vector3.DOWN
		
@onready var gravity_label: RichTextLabel = $CanvasLayer/GravityLabel
@onready var player: RigidBody3D = $Player
@onready var cam: Marker3D = $CamRig

func _physics_process(delta):
	var input:= Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if abs(input.x) > 0.0 || abs(input.y) > 0.0:
		# if pressing direction input, set gravity to input dir
		desired_gravity = Vector3(
			input.x * tilt_limit_x * ( 2.0 / PI),
			0.0,
			input.y * tilt_limit_z * ( 2.0 / PI)
		)
	else:
		# if not, go back to normal gravity
		desired_gravity = Vector3.DOWN
	
	update_gravity(delta)
	
func _ready():
	print(cam.rotation.z)
	
func update_display(value: Vector3):
	var txt = """Gravity:
[color=red]X: %.5f
[color=green]Y: %.5f[/color]
[color=blue]Z: %.5f[/color]"""
	gravity_label.text = str(txt % [value.x, value.y, value.z])

func update_gravity(delta) -> void:
	var current_gravity: Vector3 = PhysicsServer3D.area_get_param(
			get_viewport().find_world_3d().space,
			PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)
	
	# idk why this is behaving differently than using Vector3.move_toward?? 
	# but this is what i wanted
	var new_gravity:= Vector3(
		move_toward(current_gravity.x, desired_gravity.x, tilt_speed * delta),
		move_toward(current_gravity.y, desired_gravity.y, tilt_speed * delta),
		move_toward(current_gravity.z, desired_gravity.z, tilt_speed * delta)
	)
	
	PhysicsServer3D.area_set_param(
			get_viewport().find_world_3d().space,
			PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
			new_gravity)
	
	cam.pitch = -new_gravity.z * PI * 0.5
	cam.roll = new_gravity.x * PI * 0.5
	
	update_display(new_gravity)
	
