extends Marker3D

@onready var cam: Camera3D = $Camera3D

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

var distance: float
var starting_pitch: float

func _ready():
	starting_pitch = rotation.x
	distance = cam.position.z
