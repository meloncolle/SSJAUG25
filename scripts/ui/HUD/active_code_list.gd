extends PanelContainer

@onready var text_box: RichTextLabel = $RichTextLabel

func _on_active_codes_changed():
	var active_codes: Array[String] = CheatLib.get_only_active()
	var txt:= ""
	for c in active_codes:
		txt += c + "\n"
	text_box.text = txt
	if active_codes.size() == 0:
		hide()
	else:
		show()
