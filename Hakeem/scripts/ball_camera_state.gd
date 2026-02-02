extends GameState

# Dialogue display - the logic is handled here as requested
# Call show_message() from this state to display dialogue

func enter():
	if game_manager.ballcam_3d:
		game_manager.ballcam_3d.make_current()
		print("entered ballcam state")
	# Start transition dialogues after camera has switched
	game_manager.start_transition_dialogues()

func process(delta: float) -> void:
	# Don't allow any actions while dialogue is active
	if game_manager.is_dialogue_active():
		return
	
	# Ball camera state is final - no switching back to free cam
	# Player must restart the level to get back to free cam mode
	pass

# Dialogue helper methods - call these while in ball_camera_state
func show_message(text: String, portrait: Texture2D = null, duration: float = 0.0) -> void:
	"""
	Display a dialogue message at the bottom of the screen.
	
	Args:
		text: The message to display (auto-wraps, animates letter-by-letter)
		portrait: Optional character portrait texture (null = show placeholder)
		duration: How long to show after text finishes (0 = wait for click)
	"""
	game_manager.show_dialogue(text, portrait, duration)

func hide_message() -> void:
	"""Hide the current dialogue immediately."""
	game_manager.hide_dialogue()

func is_message_active() -> bool:
	"""Check if a dialogue message is currently being displayed."""
	return game_manager.is_dialogue_active()
