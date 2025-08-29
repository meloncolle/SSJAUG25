extends Node3D
class_name BaseLevel

## The name displayed on level select screen, etc.
@export var level_name: String

var level_state: Enums.LevelState
signal level_state_changed

@export var tilt_speed:= 2.0
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_x: float = deg_to_rad(20)
@export_range(0, 90, 0.1, "radians_as_degrees") var tilt_limit_z: float = deg_to_rad(20)
@export var camera_smoothing := 5.0

var desired_gravity:= Vector3.DOWN

@export var death_height:= -1.0

@onready var cam: Marker3D = $CanvasLayer/SubViewportContainer/SubViewport/CamRig
@onready var keygen: Control = $CanvasLayer/Keygen

@onready var spawn_point: Marker3D = $SpawnPoint
var player: RigidBody3D = null

@onready var goal: Node3D = $Track/Goal

var debug_panel = null

var input_vec := Vector2.ZERO
var cam_vec := Vector3.UP

@onready var countdown_player: AnimationPlayer = $CanvasLayer/Countdown/AnimationPlayer

# HUD stuff
#------------------

signal timer_changed
var timer:= 0.0:
	set(value):
		timer = max(value, 0.0)
		emit_signal("timer_changed", timer)

# For debug panel
signal speed_changed
signal gravity_changed
signal velocity_changed

func _ready():
	# Make sceneManager aware of level state changes
	# And this level aware of game state changes
	SceneManager.connect("game_state_changed", _on_game_state_changed)
	connect("level_state_changed", SceneManager._on_level_state_changed)
	
	# Spawn player and hookup camera follow and listen for intro finished
	spawn_player()
	player.get_node("RemoteTransform3D").set_remote_node(cam.get_path())
	player.get_node("RacerBen").connect("intro_completed", _on_intro_complete)
	
	# Listen for when passing through goalpost
	goal.connect("goal_reached", _on_goal_reached)
	
	# Listen for nana pickups
	for b in get_tree().get_nodes_in_group("banana"):
		b.connect("banana_got", _on_banana_got)
	
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
	CheatLib.connect("active_codes_changed", %ActiveCodes._on_active_codes_changed)
	
	cam.position = spawn_point.position
	
	# Load debug panel and hookup signals only on debug build
	if OS.is_debug_build() && Config.DEBUG_PANEL:
		debug_panel = load("res://_debug/debug_panel.tscn").instantiate()
		$CanvasLayer.add_child(debug_panel)
		
		connect("level_state_changed", debug_panel._on_level_state_changed)
		connect("speed_changed", debug_panel._on_speed_changed)
		connect("gravity_changed", debug_panel._on_grav_changed)
		connect("velocity_changed", debug_panel._on_vel_changed)
		
	# Connect end screen buttons
	%EndScreen.get_node("Panel/VBoxContainer/RetryButton").pressed.connect(SceneManager._on_press_restart)
	%EndScreen.get_node("Panel/VBoxContainer/QuitButton").pressed.connect(SceneManager._on_press_quit)
	# set focus on button when menu becomes visible, so its compatible with kb/controller
	%EndScreen.connect("visibility_changed", func(): if %EndScreen.visible: %EndScreen.get_node("Panel/VBoxContainer/RetryButton").grab_focus())
	
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

	if event.is_action_pressed("toggle_console"):
		keygen._on_open_requested() if !keygen.visible else keygen._on_close_requested()

func _physics_process(delta):
	if SceneManager.game_state != Enums.GameState.IN_GAME: return
	
	var input := Vector2.ZERO
	var cam_input := 0.0
	
	if level_state == Enums.LevelState.RACING:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		input_vec = input
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
	if OS.is_debug_build() && Config.DEBUG_PANEL:
		emit_signal("speed_changed", player.linear_velocity.length())
		emit_signal("velocity_changed", player.linear_velocity)

# lerp current gravity towards desired gravity @ tilt_speed. Update camera rotation to match
func update_gravity(delta) -> void:
	var current_gravity: Vector3 = PhysicsServer3D.area_get_param(
			get_viewport().find_world_3d().space,
			PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)
	
	#Complicated, and there's gotta be a more performant way, but works fine
	var delta_x = delta
	var delta_z = delta
	if ((current_gravity.x > 0 && player.linear_velocity.x < 0) || (current_gravity.x < 0 && player.linear_velocity.x > 0)):
		desired_gravity.x *= 2.5
		delta_x *= 4
	if ((current_gravity.z > 0 && player.linear_velocity.z < 0) || (current_gravity.z < 0 && player.linear_velocity.z > 0)):
		desired_gravity.z *= 2.5
		delta_z *= 4
		
	# idk why this is behaving differently than using Vector3.move_toward?? 
	# but this is what i wanted
	var new_gravity:= Vector3(
		move_toward(current_gravity.x, desired_gravity.x, tilt_speed * delta_x),
		move_toward(current_gravity.y, desired_gravity.y, tilt_speed * delta),
		move_toward(current_gravity.z, desired_gravity.z, tilt_speed * delta_z)
	)
	
	PhysicsServer3D.area_set_param(
			get_viewport().find_world_3d().space,
			PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
			new_gravity)
	
	var target_cam_vec = Vector3.UP.rotated(Vector3.FORWARD, input_vec.x * tilt_limit_x)
	target_cam_vec = target_cam_vec.rotated(Vector3.RIGHT, input_vec.y * tilt_limit_z)
	cam_vec = cam_vec.lerp(target_cam_vec, camera_smoothing * delta).normalized()
	
	cam.pitch = -cam_vec.z #-cam_vec.rotated(Vector3.UP, cam.yaw).z * PI * 0.5
	cam.roll = cam_vec.x #cam_vec.rotated(Vector3.UP, -cam.yaw).x * PI * 0.5
	
	if OS.is_debug_build() && Config.DEBUG_PANEL:
		emit_signal("gravity_changed", new_gravity)

# triggered when valid code entered in keygen
func _on_code_accepted(code: CheatCode):
	code.times_used += 1

	match code.name:
		"tinymode":
			player.size -= 1
		"bigmode":
			player.size += 1
		"toggler":
			var is_active: bool = CheatLib.is_active("toggler")
			CheatLib.set_active("toggler", !is_active)
			
			var mat: Material
			var color: Color
			
			for i in get_tree().get_nodes_in_group("toggle_A"):
				i.set_collision_layer_value(1, is_active)
				mat = i.get_child(0).get_surface_override_material(0)
				color = mat.albedo_color
				color.a = 1.0 if is_active else 0.5
				mat.albedo_color = color
				
			for i in get_tree().get_nodes_in_group("toggle_B"):
				i.set_collision_layer_value(1, !is_active)
				mat = i.get_child(0).get_surface_override_material(0)
				color = mat.albedo_color
				color.a = 0.5 if is_active else 1.0
				mat.albedo_color = color

# Read settings from config and update values in game
func _on_settings_changed():
# add to this for each addtl setting
	cam.sensitivity = Config.data.get_value("settings", "cam_sensitivity", Config.DEFAULTS["cam_sensitivity"])

func set_state(new_state: Enums.LevelState):
	level_state = new_state
	emit_signal("level_state_changed", new_state)
	
	match new_state:
		Enums.LevelState.WAIT_START:
			# todo: make this better and also do the HUD breaking anim thing
			# KYE LEVEL COUNTDOWN STARTS HERE
			countdown_player.play("3")
			await countdown_player.animation_finished
			countdown_player.play("2")
			await countdown_player.animation_finished
			countdown_player.play("1")
			await countdown_player.animation_finished
			countdown_player.play("go")
			await get_tree().create_timer(0.1).timeout
			player.do_intro()
			
		Enums.LevelState.RACING:
			pass
			
		Enums.LevelState.DYING:
			# KYE PUT FALLOFF SOUND HERE
			$Audio/fall_off.play()
			keygen._on_close_requested()
			var tween: Tween = Overlay.fade_to_black(1.0)
			await tween.finished
			player.respawn()
			tween = Overlay.fade_from_black(0.5)
			await player.finished_respawn
			cam.yaw = player.rotation.y
			await tween.finished
			Overlay.hide()
			set_state(Enums.LevelState.RACING)
			
		Enums.LevelState.END:
			keygen._on_close_requested()
			player.stop()
			cam.do_spin = true
			
func _on_game_state_changed(new_state: Enums.GameState):
	match new_state:
		Enums.GameState.IN_GAME:
			# KYE PUT UNPAUSE SOUND HERE
			$Audio/unpause.play()
			if keygen.reopen_on_resume:
				keygen.reopen_on_resume = false
				keygen.show()
			
		Enums.GameState.PAUSED:
			# KYE PUT PAUSE SOUND HERE
			$Audio/pause.play()
			if keygen.visible:
				keygen.reopen_on_resume = true
				keygen.hide()

func _on_intro_complete():
	set_state(Enums.LevelState.RACING)
	# Prevents player from rolling slightly before start
	# We should be spawning player over pretty flat ground
	player.can_sleep = false
	# KYE YOU GAIn CONTROL OF PLAYER HERE

func _on_banana_got(time_restored: float):
	# KYE PUT BANANA PICKUP SOUND HERE
	#$Audio/pickup_nana.play()
	timer -= time_restored
	# KYE PUT BANANA EATING SOUND HERE
	$Audio/eat_nana.play()
	# we'll adjust that timer to wait for eating sound
	await get_tree().create_timer(0.5).timeout
	throw_banana()

func throw_banana():
	var banana: RigidBody3D = load("res://scenes/art_scenes/thrown_banana[art].tscn").instantiate()
	self.add_child(banana)
	banana.position = player.position
	# KYE PUT BANANA THROWING SOUND HERE
	$Audio/throw_nana.play()
	
func _on_goal_reached():
	# KYE PUT PASSEDFINISHLINE SOUND HERE
	$Audio/passed_finish.play()
	set_state(Enums.LevelState.END)
	await get_tree().create_timer(3.0).timeout
	%EndScreen.show_results(timer)
	var new_hi_score: int = Save.add_new_score(level_name, timer)
	#var hi_scores = Save.data.get_value("Scores", level_name, [])
	#print(hi_scores)
