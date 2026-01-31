class_name GameManager
extends Node

@onready var ballcam_3d: Camera3D = $Ball/camera_pivot/Camera3D
@onready var freecam_3d: Freecam3D = $Freecam3D
@onready var state_machine: StateMachine = $StateMachine

var shot_counter := 0

func _process(delta: float) -> void:
	state_machine.process(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func _on_hole_ball_entered() -> void:
	pass
	
	
