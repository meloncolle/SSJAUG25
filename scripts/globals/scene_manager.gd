extends Node

@export var levels: Array[PackedScene] = []

var game_state: Enums.GameState
var scene_instance: Node = null
var can_pause:= false
var level_idx:= 0

signal game_state_changed

@onready var start_menu: Control = $Menus/Start
@onready var pause_menu: Control = $Menus/Pause
@onready var settings_menu: Control = $Menus/Settings
@onready var level_select: Control = $Menus/LevelSelect

func _ready():
	set_state(Enums.GameState.ON_START)
	start_menu.get_node("Panel/VBoxContainer/StartButton").pressed.connect(self._on_press_start)
	start_menu.get_node("Panel/VBoxContainer/ExitButton").pressed.connect(self._on_press_exit)
	pause_menu.get_node("Panel/VBoxContainer/ResumeButton").pressed.connect(self._on_press_resume)
	pause_menu.get_node("Panel/VBoxContainer/RestartButton").pressed.connect(self._on_press_restart)
	pause_menu.get_node("Panel/VBoxContainer/SettingsButton").pressed.connect(self._on_open_settings)
	pause_menu.get_node("Panel/VBoxContainer/QuitButton").pressed.connect(self._on_press_quit)
	
	# set focus on button when menu becomes visible, so its compatible with kb/controller
	start_menu.connect("visibility_changed", func(): if start_menu.visible: start_menu.get_node("Panel/VBoxContainer/StartButton").grab_focus())
	pause_menu.connect("visibility_changed", func(): if pause_menu.visible: pause_menu.get_node("Panel/VBoxContainer/ResumeButton").grab_focus())
	start_menu.get_node("Panel/VBoxContainer/StartButton").grab_focus()
	level_select.connect("visibility_changed", func(): if level_select.visible: level_select.buttons[0].grab_focus() else: start_menu.get_node("Panel/VBoxContainer/StartButton").grab_focus())

	# Hookup level select buttons
	for i in range(level_select.buttons.size()):
		level_select.buttons[i].connect("pressed", func(): self._on_press_level(i))
	level_select.back_button.connect("pressed", func(): level_select.hide())

	settings_menu.connect("settings_closed", _on_settings_closed)
	
	if OS.is_debug_build():
		if 0 <= Config.SKIP_TO_LEVEL && Config.SKIP_TO_LEVEL < level_select.buttons.size():
			_on_press_level(Config.SKIP_TO_LEVEL)


func _input (event: InputEvent):
	if(game_state != Enums.GameState.ON_START && can_pause && event.is_action_pressed("pause")):
		match game_state:
			Enums.GameState.IN_GAME:
				set_state(Enums.GameState.PAUSED)
				
			Enums.GameState.PAUSED:
				set_state(Enums.GameState.IN_GAME)
	
func set_state(new_state: Enums.GameState):
	emit_signal("game_state_changed", new_state)
	game_state = new_state
	match new_state:
		Enums.GameState.ON_START:
			get_tree().paused = false
			start_menu.visible = true
			pause_menu.visible = false
			
		Enums.GameState.IN_GAME:
			get_tree().paused = false
			start_menu.visible = false
			pause_menu.visible = false
			
		Enums.GameState.PAUSED:
			get_tree().paused = true
			pause_menu.visible = true	

func _on_press_start():
	level_select.show()
	
func _on_press_level(idx: int):
	level_idx = idx
	level_select.hide()
	scene_instance = load(levels[idx].resource_path).instantiate()
	self.add_child(scene_instance)
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_exit():
	get_tree().quit()
	
func _on_press_resume():
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_restart():
	scene_instance.queue_free()
	scene_instance = load(levels[level_idx].resource_path).instantiate()
	self.add_child(scene_instance)
	set_state(Enums.GameState.IN_GAME)

func _on_open_settings():
	pause_menu.visible = false
	settings_menu.visible = true
	
func _on_settings_closed():	
	settings_menu.visible = false
	pause_menu.visible = true
	
func _on_press_quit():
	if (is_instance_valid(scene_instance)):
		scene_instance.queue_free()
	scene_instance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
	
func _on_level_state_changed(new_state: Enums.LevelState):
	# We should only be able to pause during RACING... so it doesnt mess w/ fading
	match new_state:
		Enums.LevelState.WAIT_START:
			can_pause = false
			
		Enums.LevelState.RACING:
			can_pause = true
			
		Enums.LevelState.DYING:
			can_pause = false
			
		Enums.LevelState.END:
			can_pause = false
