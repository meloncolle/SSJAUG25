extends Node3D

var level_state: Enums.LevelState

@export var tilt_speed:= 2.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_x: float = PI / 4.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_z: float = PI / 4.0

var desired_gravity:= Vector3.DOWN

@onready var cam: Marker3D = $CanvasLayer/SubViewportContainer/SubViewport/CamRig
@onready var keygen: Window = $Keygen

@onready var spawn_point: Marker3D = $SpawnPoint
var player: RigidBody3D = null

func _ready():
	keygen.connect("code_accepted", _on_code_accepted)
	SceneManager.settings_menu.connect("settings_changed", _on_settings_changed)
	# sync settings with config
	_on_settings_changed()
	
	cam.position = spawn_point.position
	
	spawn_player()
	print(get_path_to(cam))
	player.get_node("RemoteTransform3D").set_remote_node(cam.get_path())
	player.get_node("RacerBen").connect("intro_completed", func(): set_state(Enums.LevelState.RACING))
	set_state(Enums.LevelState.WAIT_START)

# Load in player scene if not present, and set position to spawn_point
func spawn_player():
	print_debug("Spawning player at: " + str(spawn_point.position))
	if player == null:
		player = load("res://scenes/prefab_scenes/player.tscn").instantiate()
		self.add_child(player)
	
	player.position = spawn_point.position
	# todo: probably reset velocity and stuff if we're respawning

# Handle pause and keygen toggle since we don't need to poll for them like movement
func _input(event):
	if level_state != Enums.LevelState.RACING: return
	
	if event.is_action_pressed("pause"):
		# if keygen was open while we paused, we want to reopen during unpause
		if keygen.reopen_on_resume:
			# not using _on_open_requested bc don't want to reset entry/etc
			keygen.show()
			keygen.text_entry.grab_focus()
			keygen.reopen_on_resume = false

	if SceneManager.game_state != Enums.GameState.IN_GAME: return

	if event.is_action_pressed("toggle_console"):
		keygen._on_open_requested() if !keygen.visible else keygen._on_close_requested()

func _physics_process(delta):
	if SceneManager.game_state != Enums.GameState.IN_GAME: return
	
	var input := Vector2.ZERO
	var cam_input := 0.0
	
	if level_state == Enums.LevelState.RACING:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		# Disable cam while keygen input accepted
		if !keygen.visible: cam_input = Input.get_axis("cam_left", "cam_right") 
	
	if abs(cam_input) > 0.0 || abs(cam_input) > 0.0:
		cam.yaw -= cam_input * cam.sensitivity
	
	if abs(input.x) > 0.0 || abs(input.y) > 0.0:
		# if pressing direction input, set gravity to input dir
		# scaled to tilt limit and rotated to match camera facing
		desired_gravity = Vector3(
			input.x * tilt_limit_x * ( 2.0 / PI),
			0.0,
			input.y * tilt_limit_z * ( 2.0 / PI)
		).rotated(Vector3.UP, cam.yaw)
	else:
		# if not, go back to normal gravity
		desired_gravity = Vector3.DOWN
	
	# if not touching track, push player down. avoids 'climbing' walls, and helps fall if we get off course
	# in this scene, track pieces (not walls) were manually added to groups. should be handled better in real lvls
	if player.get_contact_count() == 0:
		desired_gravity.y = -1
	elif player.get_colliding_bodies().all(func(b): return !b.is_in_group("track")):
		desired_gravity.y = -1

	update_gravity(delta)	
	#update_display({"speed": player.linear_velocity.length()})

# lerp current gravity towards desired gravity @ tilt_speed. Update camera rotation to match
func update_gravity(delta) -> void:
	var current_gravity: Vector3 = PhysicsServer3D.area_get_param(
			get_viewport().find_world_3d().space,
			PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)
	
	# idk why this is behaving differently than using Vector3.move_toward?? 
	# but this is what i wanted
	var new_gravity:= Vector3(
		move_toward(current_gravity.x, desired_gravity.x, tilt_speed * delta),
		move_toward(current_gravity.y, desired_gravity.y, tilt_speed * delta),
		move_toward(current_gravity.z, desired_gravity.z, tilt_speed * delta)
	)
	
	PhysicsServer3D.area_set_param(
			get_viewport().find_world_3d().space,
			PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
			new_gravity)
	
	cam.pitch = -new_gravity.rotated(Vector3.UP, cam.yaw).z * PI * 0.5
	cam.roll = new_gravity.rotated(Vector3.UP, -cam.yaw).x * PI * 0.5
	
	#update_display({"gravity": new_gravity})

# triggered when valid code entered in keygen
func _on_code_accepted(code: CheatCode):
	code.times_used += 1
	
	print("CODE ACCEPTED")
	print(code.get_string())
	print("\n")

	# i guess we have to define the effects here?
	# itd be ideal to put them in the cheatcode resource but
	# idk how to do that with scope TODO?
	match code.name:
		"Test Code 1":
			print("this is the first cheat activating")
		"Test code TWO":
			print("thsi is the 2nd cheat activating")

# Read settings from config and update values in game
func _on_settings_changed():
# add to this for each addtl setting
	cam.sensitivity = Config.data.get_value("settings", "cam_sensitivity", Config.DEFAULTS["cam_sensitivity"])

func set_state(new_state: Enums.LevelState):
	match new_state:
		Enums.LevelState.WAIT_START:
			#disable input
			pass
			
		Enums.LevelState.RACING:
			#enable input
			pass
			
		Enums.LevelState.DYING:
			#hide keygen
			pass
			
		Enums.LevelState.END:
			#hide keygen
			pass
			
	level_state = new_state
	print(Enums.LevelState.keys()[new_state])
