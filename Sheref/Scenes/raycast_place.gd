extends RayCast3D

@export var building_scene: PackedScene
@onready var freecam_3d: Freecam3D = %Freecam3D

@export var grid_size: float = 1.0

var ghost_instance: Node3D

func _process(_delta: float) -> void:
	if is_colliding() && freecam_3d.movement_active:
		if building_scene and not ghost_instance:
			ghost_instance = building_scene.instantiate()
			get_tree().root.add_child(ghost_instance)
			
			# Trigger the ghost effect
			if ghost_instance.has_method("set_as_ghost"):
				ghost_instance.set_as_ghost(true)

		# Snapping logic
		var point = get_collision_point()
		var normal = get_collision_normal()
		point = (point + normal * (grid_size / 2.0))
		point = (point / grid_size).round() * grid_size
		
		if ghost_instance:
			ghost_instance.global_position = point
			ghost_instance.visible = true
			
		# Place building on click
		if Input.is_action_just_pressed("left_mb"): # Or "mouse_left"
			place_building()
	else:
		if ghost_instance: ghost_instance.visible = false

func place_building():
	if freecam_3d.movement_active:
		if ghost_instance:
			# Turn it into a real building
			if ghost_instance.has_method("set_as_ghost"):
				ghost_instance.set_as_ghost(false)
			# Clear the reference so the next frame spawns a new ghost
			ghost_instance = null
