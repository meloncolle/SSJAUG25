@tool
extends Node3D

class_name Billboard

@onready var banners: MeshInstance3D = $Banners

var time_since_last_frame: float = 0.0
var frame_size = Vector2(128.0, 64.0)
@export var frame_delay: float = 1.0

@export_group("Billboard 1")
var frame_coords_1:= Vector2.ONE
var uv_scale_1:= Vector2.ONE

var current_frame_1: int = 1:
	set(val):
		if val > frame_count_1 or val < 1:
			val = 1
		current_frame_1 = val
			
		var offset_y: int = ceil((current_frame_1 + 1) / frame_coords_1.x)
		var offset_x: int = (current_frame_1 + 1) - ((offset_y - 1) * frame_coords_1.x)
		var offset:= Vector2(offset_x * uv_scale_1.x, offset_y * uv_scale_1.y)
		var mat: Material
		for i in [4,7]:
			mat = banners.get_surface_override_material(i)
			mat.set_shader_parameter("UvOffset", offset)
		

@export var texture_1: Texture2D:
	set(tex): 
		texture_1 = tex
		
		if texture_1 != null:
			frame_coords_1 = tex.get_size() / frame_size
			uv_scale_1 = Vector2(1.0 / frame_coords_1.x, 1.0 / frame_coords_1.y)
			frame_count_1 = frame_coords_1.x * frame_coords_1.y
			assert(frame_coords_1 == Vector2(floor(frame_coords_1.x), (frame_coords_1.y)), 
			"Bad texture size! Expected multiple of %v. Got %v." % [frame_size, tex.get_size()])
		
		var mat: Material
		for i in [4,7]:
			mat = banners.get_surface_override_material(i)
			mat.set_shader_parameter("UvScale", uv_scale_1)
			mat.set_shader_parameter("diffuse_tex", tex)
		
@export var frame_count_1: int = 1:
	set(val):
		frame_count_1 = clamp(val, 1, frame_coords_1.x * frame_coords_1.y)


@export_group("Billboard 2")
var frame_coords_2:= Vector2.ONE
var uv_scale_2:= Vector2.ONE

var current_frame_2: int = 1:
	set(val):
		if val > frame_count_2 or val < 1:
			val = 1
		current_frame_2 = val
			
		var offset_y: int = ceil((current_frame_2 + 1) / frame_coords_2.x)
		var offset_x: int = (current_frame_2 + 1) - ((offset_y - 1) * frame_coords_2.x)
		var offset:= Vector2(offset_x * uv_scale_2.x, offset_y * uv_scale_2.y)
		var mat: Material
		for i in [3,6]:
			mat = banners.get_surface_override_material(i)
			mat.set_shader_parameter("UvOffset", offset)

@export var texture_2: Texture2D:
	set(tex):
		texture_2 = tex
		
		if texture_2 != null:
			frame_coords_2 = tex.get_size() / frame_size
			uv_scale_2 = Vector2(1.0 / frame_coords_2.x, 1.0 / frame_coords_2.y)
			frame_count_2 = frame_coords_2.x * frame_coords_2.y
			assert(frame_coords_2 == Vector2(floor(frame_coords_2.x), (frame_coords_2.y)), 
			"Bad texture size! Expected multiple of %v. Got %v." % [frame_size, tex.get_size()])
		
		var mat: Material
		for i in [3,6]:
			mat = banners.get_surface_override_material(i)
			mat.set_shader_parameter("UvScale", uv_scale_2)
			mat.set_shader_parameter("diffuse_tex", tex)
		
@export var frame_count_2: int = 1:
	set(val):
		frame_count_2 = clamp(val, 1, frame_coords_2.x * frame_coords_2.y)

		
@export_group("Billboard 3")
var frame_coords_3:= Vector2.ONE
var uv_scale_3:= Vector2.ONE

var current_frame_3: int = 1:
	set(val):
		if val > frame_count_3 or val < 1:
			val = 1
		current_frame_3 = val
			
		var offset_y: int = ceil((current_frame_3 + 1) / frame_coords_3.x)
		var offset_x: int = (current_frame_3 + 1) - ((offset_y - 1) * frame_coords_3.x)
		var offset:= Vector2(offset_x * uv_scale_3.x, offset_y * uv_scale_3.y)
		var mat: Material
		for i in [0,5]:
			mat = banners.get_surface_override_material(i)
			mat.set_shader_parameter("UvOffset", offset)

@export var texture_3: Texture2D:
	set(tex):
		texture_3 = tex
		
		if texture_3 != null:
			frame_coords_3 = tex.get_size() / frame_size
			uv_scale_3 = Vector2(1.0 / frame_coords_3.x, 1.0 / frame_coords_3.y)
			frame_count_3 = frame_coords_3.x * frame_coords_3.y
			assert(frame_coords_3 == Vector2(floor(frame_coords_3.x), (frame_coords_3.y)), 
			"Bad texture size! Expected multiple of %v. Got %v." % [frame_size, tex.get_size()])
		
		var mat: Material
		for i in [0,5]:
			mat = banners.get_surface_override_material(i)
			mat.set_shader_parameter("UvScale", uv_scale_3)
			mat.set_shader_parameter("diffuse_tex", tex)

@export var frame_count_3: int = 1:
	set(val):
		frame_count_3 = clamp(val, 1, frame_coords_3.x * frame_coords_3.y)
		
		
func _ready():
	texture_1 = texture_1
	texture_2 = texture_2
	texture_3 = texture_3


func _process(delta):
	if delta:
		time_since_last_frame += delta
	if time_since_last_frame >= frame_delay:
		current_frame_1 += 1
		current_frame_2 += 1
		current_frame_3 += 1
		time_since_last_frame = 0.0
