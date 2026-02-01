class_name GameManager
extends Node

@onready var ballcam_3d: Camera3D = $Ball/camera_pivot/Camera3D
@onready var freecam_3d: Freecam3D = $Freecam3D
@onready var state_machine: StateMachine = $StateMachine
@onready var ray_cast: RayCast3D = $Freecam3D/RayCast3D
@onready var ghost_tooltip: Panel = $ui/ghost_tooltip
@onready var game_ui: CanvasLayer = $GameUI
@onready var ball: GolfBall = $Ball

const ghost_scenes := {
	"push_ghost": preload("uid://lflf1mx6vwgp"),
	"pull_ghost": preload("uid://drpyecvpqsojc"),
	"bounce_ghost": preload("res://Sheref/Scenes/bounce_ghost.tscn"),
	"slow_ghost": preload("res://Sheref/Scenes/slow_ghost.tscn"),
}

var shot_counter := 0

func _ready() -> void:
	# Connect ball shot signal to track shots
	if ball:
		ball.just_shot.connect(_on_ball_shot)
	
	# Connect GameUI signals
	if game_ui:
		game_ui.restart_requested.connect(_on_restart_requested)
		game_ui.menu_requested.connect(_on_menu_requested)
		game_ui.continue_requested.connect(_on_continue_requested)
	
	# Reset game data for new game
	if GameData:
		GameData.reset_game()

func _process(delta: float) -> void:
	state_machine.process(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func _on_ball_shot() -> void:
	shot_counter += 1
	if GameData:
		GameData.add_shot()
	print("Shot count: ", shot_counter)

#win condition
func _on_hole_ball_entered() -> void:
	print("WIN! Shots: ", shot_counter)
	if AudioManager:
		AudioManager.play_win()
	if game_ui:
		game_ui.current_shots = shot_counter
		game_ui.show_win_screen()

func _on_ghost_selector_changed_ghost_selection(button) -> void:
	if not ghost_scenes.has(button):
		print("Ghost type not found: ", button)
		return
	if ray_cast.ghost_instance:
		ray_cast.ghost_instance.queue_free() #clear ghost instance to immediately switch to the new ghost type
	ray_cast.ghost_instance = null
	ray_cast.building_scene = ghost_scenes[button]
	ghost_tooltip.ghost_type = button
	
#lose condition
func _on_killzone_death() -> void:
	print("DEATH! Out of bounds.")
	if AudioManager:
		AudioManager.play_lose()
	if game_ui:
		game_ui.show_lose_screen()

func _on_restart_requested() -> void:
	shot_counter = 0
	if GameData:
		GameData.reset_game()
	get_tree().reload_current_scene()

func _on_menu_requested() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_continue_requested() -> void:
	# For now, just reload the same level
	# In a full game, this would load the next level
	shot_counter = 0
	if GameData:
		GameData.reset_game()
	get_tree().reload_current_scene()
	ray_cast.clear_ghosts()
	state_machine.on_child_transition(state_machine.current_state, "ball_cam_state")
