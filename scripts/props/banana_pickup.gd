@tool
extends Node3D
@onready var banana: MeshInstance3D = $Cylinder
@export var anim_time_offset:= 0.0

signal banana_got

var time_restored:= 1.0

var spin_speed:= 3.5
var freq:= 2.5
var amp:= 0.25

var time := 0.0

func _process(delta):
	time += fmod(delta, 2 * PI)
	banana.rotation.y = fmod((banana.rotation.y + delta * spin_speed), 2 * PI)
	banana.position.y = sin((time + anim_time_offset)* freq) * amp
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		emit_signal("banana_got", time_restored)
		queue_free()
