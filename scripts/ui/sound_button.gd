extends TextureButton
class_name SoundButton

const BUTTON_SIZE:= Vector2(300, 75)
const FRAME_COUNT:= Vector2(3, 8)
const FRAME_DELAY:= 0.1

@onready var label: Label = $Label

var time_since_last_frame: float = 0.0
var current_frame: int = 1:  
	set(val):
		if val > (FRAME_COUNT.x * FRAME_COUNT.y) or val < 1:
			val = 1
		current_frame = val
		var region_y: int = ceil(current_frame / FRAME_COUNT.x) - 1
		var region_x: int = current_frame - (region_y * FRAME_COUNT.x) - 1
		texture_focused.region = Rect2(region_x * BUTTON_SIZE.x, region_y * BUTTON_SIZE.y, BUTTON_SIZE.x, BUTTON_SIZE.y)


func _ready():
	connect("focus_entered", _on_focused)
	connect("focus_exited", _on_unfocused)
	connect("pressed", _on_pressed)

func _process(delta):
	if texture_focused is not AtlasTexture: return
	if delta:
		time_since_last_frame += delta
	if time_since_last_frame >= FRAME_DELAY:
		current_frame += 1
		time_since_last_frame = 0.0

# ok so this is gonna fire automatically when the menu opens once, gotta find a workaround
func _on_focused():
	# KYE PUT UINAVIGATE SOUND HERE (and delete print statement)
	#$Audio/UInavigate.play()
	if label: label.label_settings.font_color = Color.WHITE
	
func _on_unfocused():
	if label: label.label_settings.font_color = Color.DIM_GRAY
	
func _on_pressed():
		# KYE PUT UISELECT SOUND HERE
		#$Audio/UIselect.play()
	pass
