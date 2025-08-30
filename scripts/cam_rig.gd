extends Marker3D

@onready var cam: Camera3D = $PlayerCam
@export var bg_cam: Camera3D # mirror pitch + yaw (not roll) to bg

var distance: float
var starting_pitch: float

var do_spin: bool = false

@export_range(-180, 180, 0.1, "radians_as_degrees") var pitch = 0.0:
	set(value):
		pitch = fmod(value, 2.0 * PI) + starting_pitch
		rotation.x = pitch
		
@export_range(-180, 180, 0.1, "radians_as_degrees") var roll = 0.0:
	set(value):
		roll = fmod(value, 2.0 * PI)
		cam.rotation.z = roll
		
@export_range(-180, 180, 0.1, "radians_as_degrees") var yaw = 0.0:
	set(value):
		yaw = fmod(value, 2.0 * PI)
		rotation.y = yaw
		
@export var sensitivity:= 0.05

func _process(delta):
	if bg_cam:
		bg_cam.global_position = cam.global_position
		bg_cam.global_rotation.y = cam.global_rotation.y
	
	if do_spin:
		yaw += 2.0 * delta

func _ready():
	if bg_cam: bg_cam.global_rotation.x = cam.global_rotation.x
	starting_pitch = rotation.x
	distance = cam.position.z
