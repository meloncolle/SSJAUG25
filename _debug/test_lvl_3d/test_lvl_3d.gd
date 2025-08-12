# todo: add some sort of logic to switch directions faster. overcome inertia?
# stuff that affects ball feel (these are all on Player node):
# - speed limit
# - mass
# - gravity scale
# - damping

extends Node3D

@export var tilt_speed:= 2.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_x: float = PI / 4.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_z: float = PI / 4.0

var desired_gravity:= Vector3.DOWN

@onready var speed_label: RichTextLabel = $CanvasLayer/SpeedLabel
@onready var gravity_label: RichTextLabel = $CanvasLayer/GravityLabel
@onready var player: RigidBody3D = $Player
@onready var cam: Marker3D = $CamRig
@onready var keygen: Window = $Keygen

func _ready():
	keygen.connect("code_accepted", _on_code_accepted)

func _input(event):
	if event.is_action_pressed("toggle_console"):
		keygen._on_open_requested() if !keygen.visible else keygen._on_close_requested()

func _physics_process(delta):
	var input:= Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam_input:= Input.get_axis("cam_left", "cam_right")
	
	if abs(cam_input) > 0.0 || abs(cam_input) > 0.0:
		# todo: smooth this?
		cam.yaw -= cam_input * cam.sensitivity
	
	if abs(input.x) > 0.0 || abs(input.y) > 0.0:
		# if pressing direction input, set gravity to input dir
		# scaled to tilt limit and rotated to match camera facing
		desired_gravity = Vector3(
			input.x * tilt_limit_x * ( 2.0 / PI),
			0.0,
			input.y * tilt_limit_z * ( 2.0 / PI)
		).rotated(Vector3.UP, cam.yaw)
	else:
		# if not, go back to normal gravity
		desired_gravity = Vector3.DOWN
	
	# if not touching track, push player down. avoids 'climbing' walls, and helps fall if we get off course
	# in this scene, track pieces (not walls) were manually added to groups. should be handled better in real lvls
	if player.get_contact_count() == 0:
		desired_gravity.y = -1
	elif player.get_colliding_bodies().all(func(b): return !b.is_in_group("track")):
		desired_gravity.y = -1

	update_gravity(delta)	
	update_display({"speed": player.linear_velocity.length()})


func update_display(vals: Dictionary):
	var txt: String
	if vals.has("gravity"):
		txt = """Gravity:
[color=red]X: %.5f
[color=green]Y: %.5f[/color]
[color=blue]Z: %.5f[/color]"""
		gravity_label.text = str(txt % [vals["gravity"].x, vals["gravity"].y, vals["gravity"].z])
		
	if vals.has("speed"):
		txt = "Speed: %.5f"
		speed_label.text = str(txt % [vals["speed"]])


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
	
	cam.pitch = -new_gravity.rotated(Vector3.UP, cam.yaw).z * PI * 0.5
	cam.roll = new_gravity.rotated(Vector3.UP, -cam.yaw).x * PI * 0.5
	
	update_display({"gravity": new_gravity})

func _on_code_accepted(code: String):
	print("Code accepted: " + code)
	# we can literally do whatever here i guess
	match code:
		"imscared":
			player.speed_limit = 3
