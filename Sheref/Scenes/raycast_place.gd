extends RayCast3D

@export var building_scene: PackedScene
@onready var freecam_3d: Freecam3D = %Freecam3D
@onready var ball: GolfBall = $"../../Ball"

@export var grid_size: float = 1.0

var ghost_instance: Node3D
var ghost_list: Array[Node3D]

func _process(_delta: float) -> void:
	if is_colliding() && freecam_3d.movement_active:
		if building_scene and not ghost_instance:
			ghost_instance = building_scene.instantiate()
			get_tree().current_scene.add_child(ghost_instance)
			
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

func is_tile_occupied(position: Vector3) -> bool:
	for ghost in ghost_list:
		if ghost.global_position.is_equal_approx(position):
			return true
	return false

func place_building():
	if freecam_3d.movement_active:
		if ghost_instance:
			var target_pos = ghost_instance.global_position
			
			# Check if tile is already occupied
			if is_tile_occupied(target_pos):
				print("tile already occupied")
				return
			
			var ghost_distance_from_ball = target_pos - ball.global_position
			if ghost_distance_from_ball.length() >= 4.0:
				# Turn it into a real building
				if ghost_instance.has_method("set_as_ghost"):
					ghost_instance.set_as_ghost(false)
				ghost_list.append(ghost_instance)
				# Clear the reference so the next frame spawns a new ghost
				ghost_instance = null
			else:
				print("ghost too close to ball")
			
func clear_ghosts():
	for ghost in ghost_list:
		ghost.queue_free()
	if ghost_instance:
		ghost_instance.queue_free()
