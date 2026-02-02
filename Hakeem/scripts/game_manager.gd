class_name GameManager
extends Node
@export var nextSecene: PackedScene
@onready var ballcam_3d: Camera3D = $Ball/camera_pivot/Camera3D
@onready var freecam_3d: Freecam3D = $Freecam3D
@onready var state_machine: StateMachine = $StateMachine
@onready var ray_cast: RayCast3D = $Freecam3D/RayCast3D
@onready var ghost_tooltip: Panel = $ui/ghost_tooltip
@onready var game_ui: CanvasLayer = $GameUI
@onready var ball: GolfBall = $Ball
@onready var dialogue_box: CanvasLayer = $DialogueBox

const ghost_scenes := {
	"push_ghost": preload("uid://lflf1mx6vwgp"),
	"pull_ghost": preload("uid://drpyecvpqsojc"),
	"bounce_ghost": preload("res://Sheref/Scenes/bounce_ghost.tscn"),
	"slow_ghost": preload("res://Sheref/Scenes/slow_ghost.tscn"),
}

var shot_counter := 0

# Character portraits
var wizard_portrait: Texture2D = preload("res://Hakeem/assets/portraits/wizard_portrait.png")
var reporter_portrait: Texture2D = null

# Character enum for easy reference
enum Character {WIZARD, REPORTER}

# ============================================================================
# DIALOGUE SYSTEM
# ============================================================================
# Format: Each entry is "CHARACTER:message" where CHARACTER is WIZARD or REPORTER
# Example: "WIZARD:Hello there!" or "REPORTER:What's happening?"

@export_group("Intro Dialogues (Before Free Cam)")
## Dialogues before free cam starts. Format: "WIZARD:text" or "REPORTER:text"
@export var intro_dialogues: Array[String] = [
	"WIZARD:Welcome, young wizard! This is a magical golf course.",
	"WIZARD:Use WASD to move the camera and look around with the mouse.",
	"WIZARD:Click to place ghosts that will affect the ball's trajectory.",
	"WIZARD:Once you're ready, press B to switch to ball mode and take your shot!",
]

@export_group("Transition Dialogues (After Free Cam)")
## Dialogues after pressing B, before ball mode starts. Format: "WIZARD:text" or "REPORTER:text"
@export var transition_dialogues: Array[String] = [
	"REPORTER:And we're live! The mysterious wizard golfer is about to take their shot!",
	"WIZARD:Just watch and learn...",
	"REPORTER:The tension is palpable! What supernatural forces will they unleash?",
]

@export_group("Dialogue Settings")
## Duration each dialogue stays on screen (0 = wait for click)
@export var dialogue_duration: float = 10.0

# Dialogue state tracking
var current_dialogue_index: int = 0
var current_dialogue_array: Array[String] = []
var intro_complete: bool = false
var transition_complete: bool = false
var _dialogue_callback: Callable

# Input blocking after dialogue finishes
var input_blocked: bool = false
const INPUT_BLOCK_DURATION: float = 0.15 # seconds to block input after dialogue

func _ready() -> void:
	# Load reporter portrait (with fallback)
	_load_reporter_portrait()
	
	# Connect ball shot signal to track shots
	if ball:
		ball.just_shot.connect(_on_ball_shot)
	
	# Connect GameUI signals
	if game_ui:
		game_ui.restart_requested.connect(_on_restart_requested)
		game_ui.menu_requested.connect(_on_menu_requested)
		game_ui.continue_requested.connect(_on_continue_requested)
	
	# Connect EventBus signals
	if EventBus:
		EventBus.ghost_force_applied.connect(_on_ghost_force_applied)
		EventBus.dialogue_finished.connect(_on_dialogue_finished)
	
	# Reset game data for new game
	if GameData:
		GameData.reset_game()
	ray_cast.clear_ghosts()
	
	# Mark intro as complete if there are no intro dialogues
	# (dialogues are now triggered from free_camera_state after camera switch)
	if intro_dialogues.size() == 0:
		intro_complete = true

func _load_reporter_portrait() -> void:
	var reporter_path = "res://Hakeem/assets/portraits/reporter_portrait.png"
	if ResourceLoader.exists(reporter_path):
		reporter_portrait = load(reporter_path)
	else:
		reporter_portrait = null # Will show empty portrait

func _get_portrait_for_character(character: Character) -> Texture2D:
	match character:
		Character.WIZARD:
			return wizard_portrait
		Character.REPORTER:
			return reporter_portrait
	return null

func _parse_dialogue_line(line: String) -> Dictionary:
	"""Parse a dialogue line in format 'CHARACTER:message' and return {character, text, portrait}"""
	var result = {"character": Character.WIZARD, "text": line, "portrait": wizard_portrait}
	
	if line.begins_with("WIZARD:"):
		result.text = line.substr(7) # Remove "WIZARD:"
		result.character = Character.WIZARD
		result.portrait = wizard_portrait
	elif line.begins_with("REPORTER:"):
		result.text = line.substr(9) # Remove "REPORTER:"
		result.character = Character.REPORTER
		result.portrait = reporter_portrait
	# If no prefix, default to wizard
	
	return result

# ============================================================================
# INTRO DIALOGUES (Before Free Cam)
# ============================================================================
func _start_intro_dialogues() -> void:
	current_dialogue_array = intro_dialogues
	current_dialogue_index = 0
	_dialogue_callback = _on_intro_dialogue_complete
	_show_next_dialogue()

func _on_intro_dialogue_complete() -> void:
	intro_complete = true

func is_intro_complete() -> bool:
	return intro_complete

# ============================================================================
# TRANSITION DIALOGUES (After Free Cam, Before Ball Mode)
# ============================================================================
func start_transition_dialogues() -> void:
	"""Call this when free cam ends to start transition dialogues"""
	if transition_dialogues.size() > 0:
		current_dialogue_array = transition_dialogues
		current_dialogue_index = 0
		transition_complete = false
		_dialogue_callback = _on_transition_dialogue_complete
		_show_next_dialogue()
	else:
		transition_complete = true

func _on_transition_dialogue_complete() -> void:
	transition_complete = true

func is_transition_complete() -> bool:
	return transition_complete

# ============================================================================
# DIALOGUE PLAYBACK ENGINE
# ============================================================================
func _show_next_dialogue() -> void:
	if current_dialogue_index < current_dialogue_array.size():
		var parsed = _parse_dialogue_line(current_dialogue_array[current_dialogue_index])
		EventBus.emit_dialogue(parsed.text, parsed.portrait, dialogue_duration)
	else:
		# All dialogues finished
		if _dialogue_callback.is_valid():
			_dialogue_callback.call()

func _on_dialogue_finished() -> void:
	# Block input briefly to prevent dismiss click from triggering other actions
	_start_input_block()
	
	# Only process if we're in a dialogue sequence
	if current_dialogue_array.size() > 0 and current_dialogue_index < current_dialogue_array.size():
		current_dialogue_index += 1
		if current_dialogue_index < current_dialogue_array.size():
			# Small delay before showing next dialogue
			get_tree().create_timer(0.2).timeout.connect(_show_next_dialogue)
		else:
			# Sequence complete
			if _dialogue_callback.is_valid():
				_dialogue_callback.call()
			current_dialogue_array = []

func _start_input_block() -> void:
	input_blocked = true
	get_tree().create_timer(INPUT_BLOCK_DURATION).timeout.connect(_end_input_block)

func _end_input_block() -> void:
	input_blocked = false

func is_input_blocked() -> bool:
	return input_blocked or is_dialogue_active()

# ============================================================================
# GAME LOGIC
# ============================================================================
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
		ray_cast.ghost_instance.queue_free() # clear ghost instance to immediately switch to the new ghost type
	ray_cast.ghost_instance = null
	ray_cast.building_scene = ghost_scenes[button]
	ray_cast.set_ghost_type(button)
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
	ray_cast.clear_ghosts()
	get_tree().reload_current_scene()

func _on_menu_requested() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_continue_requested() -> void:
	# Load the next level
	if nextSecene:
		get_tree().change_scene_to_packed(nextSecene)
	else:
		# Fallback: reload current scene if no next scene set
		get_tree().reload_current_scene()

# Dialogue System (direct API)
func show_dialogue(text: String, portrait: Texture2D = null, duration: float = 0.0) -> void:
	"""Display a dialogue message."""
	if dialogue_box:
		dialogue_box.show_dialogue(text, portrait, duration)

func hide_dialogue() -> void:
	if dialogue_box:
		dialogue_box.hide_dialogue()

func is_dialogue_active() -> bool:
	return dialogue_box and dialogue_box.is_displaying

# Event Bus Handlers
const GHOST_REACTION_DIALOGUES: Array[String] = [
	"What just happened?",
	"Woah!",
	"Did you see that?",
	"Balls shouldn't move like that...",
]

func _on_ghost_force_applied(ghost_type: int, force_power: float) -> void:
	# Show random reporter reaction when a ghost affects the ball
	var random_dialogue = GHOST_REACTION_DIALOGUES[randi() % GHOST_REACTION_DIALOGUES.size()]
	show_dialogue(random_dialogue, reporter_portrait, 1.5)
