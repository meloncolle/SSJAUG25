extends Node3D

var level_state: Enums.LevelState
signal state_changed

@export var tilt_speed:= 2.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_x: float = PI / 4.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_z: float = PI / 4.0

var desired_gravity:= Vector3.DOWN

@export var death_height:= -1.0

@onready var cam: Marker3D = $CanvasLayer/SubViewportContainer/SubViewport/CamRig
@onready var keygen: Window = $Keygen

@onready var spawn_point: Marker3D = $SpawnPoint
var player: RigidBody3D = null

var debug_panel = null

# HUD stuff
#------------------

signal timer_changed
var timer:= 0.0:
	set(value):
		timer = value
		emit_signal("timer_changed", timer)

# For debug panel
signal speed_changed
signal gravity_changed
signal velocity_changed

func _ready():
	spawn_player()
	player.get_node("RemoteTransform3D").set_remote_node(cam.get_path())
	player.get_node("RacerBen").connect("intro_completed", func(): set_state(Enums.LevelState.RACING))
	
	# Handle when valid code input
	keygen.connect("code_accepted", _on_code_accepted)
	# Update game values when settings changed in menu
	SceneManager.settings_menu.connect("settings_changed", _on_settings_changed)
	# sync settings with config
	_on_settings_changed()
	
	# Hookup update signals for HUD stuff
	connect("timer_changed", %Timer._on_timer_changed)
	connect("speed_changed", %Speedometer._on_speed_changed)
	player.connect("max_speed_changed", %Speedometer._on_max_speed_changed)
	player.emit_signal("max_speed_changed", player.max_speed)
	
	cam.position = spawn_point.position
	
	# Load debug panel and hookup signals only on debug build
	if OS.is_debug_build():
		debug_panel = load("res://_debug/debug_panel.tscn").instantiate()
		$CanvasLayer.add_child(debug_panel)
		
		connect("state_changed", debug_panel._on_state_changed)
		connect("speed_changed", debug_panel._on_speed_changed)
		connect("gravity_changed", debug_panel._on_grav_changed)
		connect("velocity_changed", debug_panel._on_vel_changed)
		
	set_state(Enums.LevelState.WAIT_START)

# Load in player scene if not present, and set position to spawn_point
func spawn_player():
	if player == null:
		player = load("res://scenes/prefab_scenes/player.tscn").instantiate()
		self.add_child(player)
	
	player.position = spawn_point.position
	player.respawn_target = spawn_point

func _process(delta):
	if (SceneManager.game_state == Enums.GameState.IN_GAME 
	&& level_state in [Enums.LevelState.RACING, Enums.LevelState.DYING]):
		timer += delta

# Handle pause and keygen toggle since we don't need to poll for them like movement
func _input(event):
	if level_state != Enums.LevelState.RACING: return
	
	if event.is_action_pressed("pause"):
		# if keygen was open while we paused, we want to reopen during unpause
		if keygen.reopen_on_resume:
			# not using _on_open_requested bc don't want to reset entry/etc
			keygen.show()
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
		
		# Check for death
		if player.global_position.y <= death_height:
			set_state(Enums.LevelState.DYING)
	
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
	if OS.is_debug_build():
		emit_signal("speed_changed", player.linear_velocity.length())
		emit_signal("velocity_changed", player.linear_velocity)

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
	
	if OS.is_debug_build():
		emit_signal("gravity_changed", new_gravity)

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
	level_state = new_state
	emit_signal("state_changed", new_state)
	
	match new_state:
		Enums.LevelState.WAIT_START:
			pass
			
		Enums.LevelState.RACING:
			pass
			
		Enums.LevelState.DYING:
			keygen._on_close_requested()
			var tween: Tween = Overlay.fade_to_black(1.0)
			await tween.finished
			player.respawn()
			cam.yaw = player.rotation.y
			tween = Overlay.fade_from_black(0.5)
			await tween.finished
			Overlay.hide()
			set_state(Enums.LevelState.RACING)
			
		Enums.LevelState.END:
			keygen._on_close_requested()
