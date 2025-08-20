extends Area3D

@onready var pole: Sprite3D = $Pole

signal checkpoint_activated

var is_activated:= false:
	set(value):
		is_activated = value
		if is_activated: 
			pole.modulate = Color.GREEN
		else:
			pole.modulate = Color.WHITE

func _on_body_entered(body: Node3D) -> void:
	if is_activated: return
	
	if body is Player:
		is_activated = true
		body.respawn_target = self
		
		# Turn off any other checkpoints
		for cp in get_tree().get_nodes_in_group("checkpoint"):
			if cp != self:
				cp.is_activated = false
