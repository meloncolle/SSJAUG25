extends Node2D

#TODO: reveal broken sprites during title sequence

const min_angle:= -50.0
const max_angle:= 190.0
const min_speed:= 0.0
var max_speed: float

@onready var base: Sprite2D = $Base
@onready var base_broken: Sprite2D = $BaseBroken
@onready var needle: Sprite2D = $Needle
@onready var glass: Sprite2D = $Glass
@onready var glass_broken: Sprite2D = $GlassBroken

@onready var target_rotation: = needle.rotation

func _process(delta):
	needle.rotation = lerpf(needle.rotation, target_rotation, delta * 10.0)

func _on_max_speed_changed(new_max_speed: float):
	max_speed = new_max_speed

func _on_speed_changed(new_speed: float):
	target_rotation = deg_to_rad(lerpf(min_angle, max_angle, new_speed / (max_speed - min_speed)))
