extends ColorRect

@onready var state_label: Label = $StateLabel
@onready var speed_label: Label = $SpeedLabel
@onready var grav_label: RichTextLabel = $GravityLabel
@onready var vel_label: RichTextLabel = $VelocityLabel

func _on_state_changed(new_state: Enums.LevelState):
	var txt := "State: %s"
	state_label.text = txt % Enums.LevelState.keys()[new_state]

func _on_speed_changed(new_speed: float):
	var txt := "Speed: %.5f"
	speed_label.text = txt % new_speed
	
func _on_grav_changed(new_grav: Vector3):
	var txt:= """Gravity:
[color=red]X:[/color] %.5f
[color=green]Y:[/color] %.5f
[color=blue]Z:[/color] %.5f"""
	grav_label.text = txt % [new_grav.x, new_grav.y, new_grav.z]
	
func _on_vel_changed(new_vel: Vector3):
	var txt:= """Lin. Velocity:
[color=red]X:[/color] %.5f
[color=green]Y:[/color] %.5f
[color=blue]Z:[/color] %.5f"""
	vel_label.text = txt % [new_vel.x, new_vel.y, new_vel.z]
