class_name StateMachine
extends Node

var current_state: State
var states: Dictionary = {}

@export var initial_state: State

var state_change_start_time: int
var state_change_cooldown := 1000
var can_change_state := true

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(on_child_transition)
	if initial_state:
		# Defer entering the initial state to ensure all @onready variables are ready
		call_deferred("_enter_initial_state")

func _enter_initial_state() -> void:
	if initial_state:
		# Check if game manager has intro dialogues that need to complete first
		var game_manager = get_parent() as GameManager
		if game_manager and not game_manager.is_intro_complete():
			# Wait for intro dialogues to finish before entering the initial state
			EventBus.dialogue_finished.connect(_check_intro_complete)
		else:
			# No intro dialogues, enter immediately
			initial_state.enter()
			current_state = initial_state

func _check_intro_complete() -> void:
	var game_manager = get_parent() as GameManager
	if game_manager and game_manager.is_intro_complete():
		EventBus.dialogue_finished.disconnect(_check_intro_complete)
		if initial_state and not current_state:
			initial_state.enter()
			current_state = initial_state
		
func process(delta: float) -> void:
	if current_state:
		current_state.process(delta)
	cooldowns()

func physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)

func cooldowns():
	var current_time = Time.get_ticks_msec()
	var delta_change_state = current_time - state_change_start_time
	
	if delta_change_state >= state_change_cooldown && !can_change_state:
		can_change_state = true

func on_child_transition(state: State, new_state_name: String):
	print("a")
	if can_change_state:
		if state != current_state:
			return
		
		var new_state: State = states.get(new_state_name.to_lower())	
		if !new_state:
			return
		
		can_change_state = false
		print("changed state")
		if current_state:
			current_state.exit()
			
		new_state.enter()
		
		current_state = new_state
