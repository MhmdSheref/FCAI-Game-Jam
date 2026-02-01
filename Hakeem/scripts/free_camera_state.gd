extends GameState
@onready var ui: Node = $"../../ui"

func enter():
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
	if Input.is_action_just_pressed("switch_cam"):
		transition.emit(self, "ball_camera_state")
		
		
