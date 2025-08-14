extends Node

@export var starting_level: PackedScene = null

var game_state: Enums.GameState
var scene_instance: Node = null

@onready var start_menu: Control = $Menus/Start
@onready var pause_menu: Control = $Menus/Pause

func _ready():
	set_state(Enums.GameState.ON_START)
	start_menu.get_node("Panel/VBoxContainer/StartButton").pressed.connect(self._on_press_start)
	start_menu.get_node("Panel/VBoxContainer/ExitButton").pressed.connect(self._on_press_exit)
	pause_menu.get_node("Panel/VBoxContainer/ResumeButton").pressed.connect(self._on_press_resume)
	pause_menu.get_node("Panel/VBoxContainer/RestartButton").pressed.connect(self._on_press_restart)
	pause_menu.get_node("Panel/VBoxContainer/QuitButton").pressed.connect(self._on_press_quit)

func _input (event: InputEvent):
	if(game_state != Enums.GameState.ON_START && event.is_action_pressed("ui_cancel")):
		get_tree().paused = !get_tree().paused
		
		match game_state:
			Enums.GameState.IN_GAME:
				set_state(Enums.GameState.PAUSED)
				
			Enums.GameState.PAUSED:
				set_state(Enums.GameState.IN_GAME)
	
func set_state(new_state: Enums.GameState):
	match new_state:
		Enums.GameState.ON_START:
			start_menu.visible = true
			pause_menu.visible = false
			
		Enums.GameState.IN_GAME:
			start_menu.visible = false
			pause_menu.visible = false
			
		Enums.GameState.PAUSED:
			pause_menu.visible = true
			
	game_state = new_state


func _on_press_start():
	scene_instance = load(starting_level.resource_path).instantiate()
	self.add_child(scene_instance)
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_exit():
	get_tree().quit()
	
func _on_press_resume():
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_restart():
	#get_tree().paused = false # Need if we play fade anim later
	scene_instance.queue_free()
	scene_instance = load(starting_level.resource_path).instantiate()
	self.add_child(scene_instance)
	set_state(Enums.GameState.IN_GAME)

	
func _on_press_quit():
	if (is_instance_valid(scene_instance)):
		scene_instance.queue_free()
	scene_instance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
