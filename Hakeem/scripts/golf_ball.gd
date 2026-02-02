class_name GolfBall
extends RigidBody3D

@export var max_speed: int = 8
@export var accel: int = 5

# Screen-based power calculation
@export var screen_power_scale := 0.005  # How much screen distance affects power
@export var max_screen_drag := 200.0     # Max screen pixels for full power

# --- Timers (seconds / milliseconds where noted) ---
@export var shoot_cooldown := 5.0          # seconds (override)
@export var speed_check_cooldown := 1000   # ms
@export var speed_settle_time := 500        # ms

# Guide line settings
@export var guide_line_scale := 4.0        # How long the guide line extends
@export var guide_line_width := 0.15       # Thickness of the guide line

@onready var scaler: Marker3D = $Scaler
@onready var camera_3d: Camera3D = $camera_pivot/Camera3D
@onready var hit_animation_player: AnimationPlayer = $hit_vfx/AnimationPlayer

# --- Input / aiming ---
var selected := false
var velocity: Vector3
var speed: Vector3
var distance: float           # 3D world distance (for direction)
var screen_distance: float    # Screen space distance (for power)
var direction: Vector3
var drag_start_pos: Vector2   # Mouse position when drag started

# --- Shot state machine ---
enum ShotState {
	READY,          # Can shoot
	IGNORE_SPEED,   # Just shot, ignore velocity
	CHECKING_SPEED  # Waiting for settle or override
}

var shot_state: ShotState = ShotState.READY

# --- Timers ---
var shoot_start_time := 0
var speed_settle_start_time := 0

signal just_shot
signal shot_ended


func _ready() -> void:
	scaler.set_as_top_level(true)


# -----------------------------
# Input handling
# -----------------------------
func _on_input_event(camera, event, position, normal, shape_idx) -> void:
	if event.is_action_pressed("left_mb"):
		# Check if input is blocked by dialogue
		var game_manager = get_node_or_null("%GameManager")
		if game_manager and game_manager.is_input_blocked():
			return
		if shot_state == ShotState.READY:
			selected = true
			drag_start_pos = get_viewport().get_mouse_position()


func _input(event) -> void:
	if event.is_action_released("left_mb") and selected:
		# Check if input is blocked by dialogue
		var game_manager = get_node_or_null("%GameManager")
		if game_manager and game_manager.is_input_blocked():
			selected = false
			return
		# Calculate power based on screen distance
		var power_factor = clamp(screen_distance / max_screen_drag, 0.0, 1.0)
		speed = -(direction * power_factor * max_speed)
		shoot(speed)

		just_shot.emit()
		shoot_start_time = Time.get_ticks_msec()
		speed_settle_start_time = 0
		shot_state = ShotState.IGNORE_SPEED

		selected = false


# -----------------------------
# Main loop
# -----------------------------
func _process(delta) -> void:
	update_state_machine()
	scaler_follow()
	pull_meter()


# -----------------------------
# State machine logic
# -----------------------------
func update_state_machine() -> void:
	var now = Time.get_ticks_msec()
	var delta_shot = now - shoot_start_time

	match shot_state:
		ShotState.READY:
			pass

		ShotState.IGNORE_SPEED:
			# Enable speed checking after delay
			if delta_shot >= speed_check_cooldown:
				shot_state = ShotState.CHECKING_SPEED
				print("ball can check speed")

			# Override cooldown
			if delta_shot >= shoot_cooldown * 1000:
				end_shot()
				print("shot ended from cooldown")

		ShotState.CHECKING_SPEED:
			# Override cooldown always wins
			if delta_shot >= shoot_cooldown * 1000:
				end_shot()
				print("shot ended from cooldown")
				return

			# Continuous stillness check
			if !is_moving():
				if speed_settle_start_time == 0:
					print("speed settle time started")
					speed_settle_start_time = now
				elif now - speed_settle_start_time >= speed_settle_time:
					end_shot()
					print("shot ended from speed settle time")
			else:
				# Movement cancels settling
				speed_settle_start_time = 0

func end_shot() -> void:
	shot_state = ShotState.READY
	speed_settle_start_time = 0
	# Zero out velocity to ensure ball is completely stopped
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	shot_ended.emit()

# -----------------------------
# Shooting
# -----------------------------
func shoot(vector: Vector3) -> void:
	velocity = Vector3(vector.x, 0.0, vector.z) 
	play_hit_particles()
	apply_impulse(velocity, Vector3.ZERO)
	# Play hit sound
	if AudioManager:
		AudioManager.play_hit()


func play_hit_particles() -> void:
	hit_animation_player.play("hit_animation")

# -----------------------------
# Helpers
# -----------------------------
func scaler_follow() -> void:
	scaler.transform.origin = scaler.transform.origin.lerp(global_transform.origin, 0.8)

func pull_meter() -> void:
	var ray_cast = camera_3d.camera_raycast()
	var current_mouse_pos = get_viewport().get_mouse_position()

	if ray_cast.is_empty():
		return

	# Calculate 3D world distance and direction (still used for direction)
	distance = global_position.distance_to(ray_cast.position)
	direction = global_transform.origin.direction_to(ray_cast.position)
	
	# Calculate screen-space distance for power (zoom-independent)
	if selected:
		screen_distance = drag_start_pos.distance_to(current_mouse_pos)
	else:
		screen_distance = 0.0

	# Make scaler look at the target
	var target = Vector3(ray_cast.position.x, global_position.y, ray_cast.position.z)
	if !scaler.global_position.is_equal_approx(target):
		scaler.look_at(target)

	if selected:
		# Scale based on power - the guide line shows how far the ball will go
		var power_factor = clamp(screen_distance / max_screen_drag, 0.0, 1.0)
		scaler.scale.z = power_factor * guide_line_scale
		scaler.scale.x = guide_line_width
		scaler.scale.y = guide_line_width
	else:
		scaler.scale.z = 0.01
		scaler.scale.x = 0.01
		scaler.scale.y = 0.01

func is_moving() -> bool:
	return linear_velocity.length() > 0.2
