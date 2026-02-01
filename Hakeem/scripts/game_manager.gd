class_name GameManager
extends Node

@onready var ballcam_3d: Camera3D = $Ball/camera_pivot/Camera3D
@onready var freecam_3d: Freecam3D = $Freecam3D
@onready var state_machine: StateMachine = $StateMachine
@onready var ray_cast: RayCast3D = $Freecam3D/RayCast3D

const ghost_scenes := {
	"push_ghost": preload("uid://lflf1mx6vwgp"),
	"pull_ghost": preload("uid://drpyecvpqsojc"),
}

var shot_counter := 0

func _process(delta: float) -> void:
	state_machine.process(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func _on_hole_ball_entered() -> void:
	pass
	


func _on_ghost_selector_changed_ghost_selection(button) -> void:
	pass
	ray_cast.building_scene = ghost_scenes[button]
