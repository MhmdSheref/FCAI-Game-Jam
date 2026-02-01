extends GameState

func enter():
	if game_manager.ballcam_3d:
		game_manager.ballcam_3d.make_current()
		print("entered ballcam  state")
	
func process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_cam"):
		transition.emit(self, "free_camera_state")
