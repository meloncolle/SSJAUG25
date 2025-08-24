@tool
extends Node3D

@export var frame_delay: float = 1.0
@onready var banner: MeshInstance3D = $Cube_002
@export var frame_count: int = 1:
	set(val):
		frame_count = clamp(val, 1, frame_coords.x * frame_coords.y)

var time_since_last_frame: float = 0.0
var frame_size = Vector2(128.0, 64.0)
var frame_coords:= Vector2.ONE
var uv_scale:= Vector2.ONE

var current_frame: int = 1:
	set(val):
		if val > frame_count or val < 1:
			val = 1
		current_frame = val
			
		var offset_y: int = ceil((current_frame + 1) / frame_coords.x)
		var offset_x: int = (current_frame + 1) - ((offset_y - 1) * frame_coords.x)
		var offset:= Vector2(offset_x * uv_scale.x, offset_y * uv_scale.y)
		var mat := banner.get_surface_override_material(0)
		mat.set_shader_parameter("UvOffset", offset)

@export var texture: Texture2D:
	set(tex): 
		texture = tex
		if banner == null: return
		var mat := banner.get_surface_override_material(0)
		
		if texture != null:
			frame_coords = tex.get_size() / frame_size
			uv_scale = Vector2(1.0 / frame_coords.x, 1.0 / frame_coords.y)
			frame_count = frame_coords.x * frame_coords.y
			print(uv_scale)
			assert(frame_coords == Vector2(floor(frame_coords.x), (frame_coords.y)), 
			"Bad texture size! Expected multiple of %v. Got %v." % [frame_size, tex.get_size()])
			
			mat.set_shader_parameter("UvScale", uv_scale)
		mat.set_shader_parameter("diffuse_tex", tex)

func _ready():
	texture = texture

func _process(delta):
	if (frame_size.x * frame_size.y) == 1: pass
	
	if delta:
		time_since_last_frame += delta
	if time_since_last_frame >= frame_delay:
		current_frame += 1
		time_since_last_frame = 0.0
