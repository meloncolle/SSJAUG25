extends Node3D

@onready var car: Node3D = $"car_solo[art]"
@onready var cam: Node3D = $CamRig

func _process(delta):
	car.rotate_y(delta)
