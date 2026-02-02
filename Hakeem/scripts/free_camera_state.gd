extends GameState
@onready var ui: Node = $"../../ui"

func enter():
	if game_manager.freecam_3d:
		game_manager.freecam_3d.make_current()
		game_manager.freecam_3d.movement_active = true
		for child: CanvasItem in ui.get_children():
			child.visible = true
		print("entered freecam state")
	# Start intro dialogues AFTER camera has switched (only if not already complete)
	if not game_manager.is_intro_complete():
		game_manager._start_intro_dialogues()
	
func exit():
	game_manager.freecam_3d.movement_active = false
	for child: CanvasItem in ui.get_children():
		child.visible = false
	
func process(delta: float) -> void:
	# Block all input during dialogue sequences
	if game_manager.is_dialogue_active():
		# Disable freecam movement during dialogues
		game_manager.freecam_3d.movement_active = false
		return
	
	# Re-enable freecam movement when not in dialogue
	if not game_manager.freecam_3d.movement_active:
		game_manager.freecam_3d.movement_active = true
	
	if Input.is_action_just_pressed("switch_cam"):
		# Switch to ball camera immediately - dialogues will play AFTER camera switch
		transition.emit(self, "ball_camera_state")
	
	# Ghost type switching with Q and E (only when not in dialogue)
	if Input.is_action_just_pressed("switch_ghost_left"):
		EventBus.switch_ghost_left_requested.emit()
	if Input.is_action_just_pressed("switch_ghost_right"):
		EventBus.switch_ghost_right_requested.emit()
