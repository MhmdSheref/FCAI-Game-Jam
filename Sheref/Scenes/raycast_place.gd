extends RayCast3D

@export var building_scene: PackedScene
@onready var freecam_3d: Freecam3D = %Freecam3D
@onready var ball: GolfBall = $"../../Ball"

@export var grid_size: float = 1.0

# Ghost placement limits per type (configurable per level)
@export_group("Ghost Limits")
@export var max_push_ghosts: int = 3
@export var max_pull_ghosts: int = 3
@export var max_bounce_ghosts: int = 3
@export var max_slow_ghosts: int = 3

var ghost_instance: Node3D
var ghost_list: Array[Node3D]
var wizard_portrait: Texture2D = preload("res://Hakeem/assets/portraits/wizard_portrait.png")

# Track current ghost type and placement counts
var current_ghost_type: String = "pull_ghost"
var ghost_counts: Dictionary = {
	"push_ghost": 0,
	"pull_ghost": 0,
	"bounce_ghost": 0,
	"slow_ghost": 0
}

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
			
		# Place building on click (only if input is not blocked by dialogue)
		var game_manager = get_node_or_null("%GameManager")
		if Input.is_action_just_pressed("left_mb") and (not game_manager or not game_manager.is_input_blocked()):
			place_building()
	else:
		if ghost_instance: ghost_instance.visible = false

func is_tile_occupied(position: Vector3) -> bool:
	for ghost in ghost_list:
		if ghost.global_position.is_equal_approx(position):
			return true
	return false

func get_max_for_type(ghost_type: String) -> int:
	match ghost_type:
		"push_ghost":
			return max_push_ghosts
		"pull_ghost":
			return max_pull_ghosts
		"bounce_ghost":
			return max_bounce_ghosts
		"slow_ghost":
			return max_slow_ghosts
	return 0

func get_remaining_for_type(ghost_type: String) -> int:
	return get_max_for_type(ghost_type) - ghost_counts.get(ghost_type, 0)

func set_ghost_type(ghost_type: String) -> void:
	current_ghost_type = ghost_type

func place_building():
	if freecam_3d.movement_active:
		if ghost_instance:
			var target_pos = ghost_instance.global_position
			
			# Check if we've reached the limit for this ghost type
			if ghost_counts.get(current_ghost_type, 0) >= get_max_for_type(current_ghost_type):
				EventBus.emit_dialogue("I've used all my ghosts of this type!", wizard_portrait, 3.0)
				return
			
			# Check if tile is already occupied
			if is_tile_occupied(target_pos):
				EventBus.emit_dialogue("I can't place two ghosts in the same spot", wizard_portrait, 3.0)
				return
			
			var ghost_distance_from_ball = target_pos - ball.global_position
			if ghost_distance_from_ball.length() >= 4.0:
				# Turn it into a real building
				if ghost_instance.has_method("set_as_ghost"):
					ghost_instance.set_as_ghost(false)
				ghost_list.append(ghost_instance)
				ghost_counts[current_ghost_type] += 1
				AudioManager.play_ghost_place()
				# Clear the reference so the next frame spawns a new ghost
				ghost_instance = null
			else:
				EventBus.emit_dialogue("I can't place the ghosts too close to the ball or people might get suspicious...", wizard_portrait, 3.0)
			
func clear_ghosts():
	for ghost in ghost_list:
		ghost.queue_free()
	if ghost_instance:
		ghost_instance.queue_free()
	ghost_instance = null
	ghost_list.clear()
	# Reset all ghost counts
	for key in ghost_counts:
		ghost_counts[key] = 0
