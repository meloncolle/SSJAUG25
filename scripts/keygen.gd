extends Window

@onready var text_entry: LineEdit = $LineEdit
@onready var submit_button: Button = $SubmitButton

signal code_accepted(code: String)
signal code_rejected(code: String)

# should this be stored elsewhere?
var valid_codes := [
	"imscared", # set max speed to 3, handled in test_lvl_3d.gd
]

func _ready():
	connect("close_requested", _on_close_requested)
	text_entry.connect("text_submitted", _on_text_submitted)
	submit_button.connect("pressed", _on_text_submitted)
	
func _input(event):
	if event.is_action_pressed("toggle_console"):
		emit_signal("close_requested")

func _on_close_requested():
	hide()

func _on_open_requested():
	$Title.text = "GROUNDWATER UNIVERSAL KEYGEN 2025"
	text_entry.clear()
	show()
	text_entry.grab_focus()
	
func _on_text_submitted(new_text: String = text_entry.text):
	if new_text in valid_codes:
		$Title.text = "[color=green]CODE ACCEPTED :)[/color]"
		await get_tree().create_timer(0.75).timeout
		emit_signal("code_accepted", new_text)
		emit_signal("close_requested")
	else:
		$Title.text = "[color=red]CODE REJECTED >:([/color]"
		await get_tree().create_timer(0.75).timeout
		emit_signal("code_rejected", new_text)
		emit_signal("close_requested")
