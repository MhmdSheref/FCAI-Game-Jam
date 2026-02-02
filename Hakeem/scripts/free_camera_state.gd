extends GameState
@onready var ui: Node = $"../../ui"

var waiting_for_transition_dialogues: bool = false

func enter():
	waiting_for_transition_dialogues = false
	if game_manager.freecam_3d:
		game_manager.freecam_3d.make_current()
		game_manager.freecam_3d.movement_active = true
		for child: CanvasItem in ui.get_children():
			child.visible = true
		print("entered freecam state")
	
func exit():
	game_manager.freecam_3d.movement_active = false
	for child: CanvasItem in ui.get_children():
		child.visible = false
	
func process(delta: float) -> void:
	# If waiting for transition dialogues to complete
	if waiting_for_transition_dialogues:
		if game_manager.is_transition_complete():
			waiting_for_transition_dialogues = false
			transition.emit(self, "ball_camera_state")
		return
	
	if Input.is_action_just_pressed("switch_cam"):
		# Start transition dialogues before switching to ball cam
		game_manager.start_transition_dialogues()
		if game_manager.is_transition_complete():
			# No transition dialogues, switch immediately
			transition.emit(self, "ball_camera_state")
		else:
			# Wait for dialogues to finish
			waiting_for_transition_dialogues = true
			# Hide the UI while dialogues play
			for child: CanvasItem in ui.get_children():
				child.visible = false
	
	# Ghost type switching with Q and E (only when not waiting for dialogues)
	if Input.is_action_just_pressed("switch_ghost_left"):
		EventBus.switch_ghost_left_requested.emit()
	if Input.is_action_just_pressed("switch_ghost_right"):
		EventBus.switch_ghost_right_requested.emit()
