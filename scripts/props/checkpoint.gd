extends Area3D

@onready var flag_off: Sprite3D = $FlagOff
@onready var flag_on: AnimatedSprite3D = $FlagOn

var is_activated:= false:
	set(value):
		is_activated = value
		flag_on.visible = is_activated
		flag_off.visible = !is_activated

func _on_body_entered(body: Node3D) -> void:
	if is_activated: return
	
	if body is Player:
		is_activated = true
		body.respawn_target = self
		
		# Turn off any other checkpoints
		for cp in get_tree().get_nodes_in_group("checkpoint"):
			if cp != self:
				cp.is_activated = false
