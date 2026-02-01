class_name GameManager
extends Node

@onready var ballcam_3d: Camera3D = $Ball/camera_pivot/Camera3D
@onready var freecam_3d: Freecam3D = $Freecam3D
@onready var state_machine: StateMachine = $StateMachine
@onready var ray_cast: RayCast3D = $Freecam3D/RayCast3D
@onready var ghost_tooltip: Panel = $ui/ghost_tooltip

const ghost_scenes := {
	"push_ghost": preload("uid://lflf1mx6vwgp"),
	"pull_ghost": preload("uid://drpyecvpqsojc"),
}

var shot_counter := 0

func _process(delta: float) -> void:
	state_machine.process(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

#win condition
func _on_hole_ball_entered() -> void:
	print("win")

func _on_ghost_selector_changed_ghost_selection(button) -> void:
	if ray_cast.ghost_instance:
		ray_cast.ghost_instance.queue_free() #clear ghost instance to immediately switch to the new ghost type
	ray_cast.ghost_instance = null
	ray_cast.building_scene = ghost_scenes[button]
	ghost_tooltip.ghost_type = button
	
#lose condition
func _on_killzone_death() -> void:
	print("ded")
	get_tree().reload_current_scene()
	ray_cast.clear_ghosts()
	state_machine.on_child_transition(state_machine.current_state, "ball_cam_state")
