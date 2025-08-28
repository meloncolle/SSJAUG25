extends Node

var using_gamepad: bool = false
signal input_type_changed

func _input(event: InputEvent):
	if event is InputEventKey:
		if using_gamepad:
			using_gamepad = false
			emit_signal("input_type_changed")

	elif event is InputEventJoypadButton:
		if !using_gamepad:
			using_gamepad = true
			emit_signal("input_type_changed")

	elif event is InputEventJoypadMotion:
		if !using_gamepad && abs(event.axis_value) > 0.5:
			using_gamepad = true
			emit_signal("input_type_changed")
