@tool
extends Node3D

class_name Billboard

@onready var banners: MeshInstance3D = $Banners

@export var board_1: Texture2D:
	set(tex): 
		board_1 = tex
		set_texture([4,7], board_1)
@export var board_2: Texture2D:
	set(tex):
		board_2 = tex
		set_texture([3,6], board_2)
@export var board_3: Texture2D:
	set(tex):
		board_3 = tex
		set_texture([0,5], board_3)

func _ready():
	board_1 = board_1
	board_2 = board_2
	board_3 = board_3

func set_texture(indices: Array[int], tex: Texture2D):
	if banners == null: return
	var mat: Material
	for i in indices:
		mat = banners.get_surface_override_material(i)
		mat.set_shader_parameter("diffuse_tex", tex)
