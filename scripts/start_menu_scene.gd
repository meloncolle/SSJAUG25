extends Node3D

@onready var car: Node3D = $"car_solo[art]"

func _process(delta):
	car.rotate_y(delta)
