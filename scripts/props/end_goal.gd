extends Node3D

signal goal_reached

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		emit_signal("goal_reached")
