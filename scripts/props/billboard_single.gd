@tool
extends Node3D

@onready var banner: MeshInstance3D = $Cube_002

@export var texture: Texture2D:
	set(tex): 
		texture = tex
		var mat := banner.get_surface_override_material(0)
		mat.set_shader_parameter("diffuse_tex", tex)
