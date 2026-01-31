extends RigidBody3D

@export var max_speed : int = 8
@export var accel : int = 5

@onready var scaler : Marker3D = $Scaler
@onready var camera_3d: Camera3D = $camera_pivot/Camera3D

var selected : bool = false
var velocity : Vector3
var speed : Vector3
var distance : float
var direction :Vector3
var is_shot : bool
var shoot_start_time : int
#timer to make the ball shootable again regardless of speed
@export var shoot_cooldown_ms := 5000
#this timer exists so that the speed check doesn't happen immediately after the ball is shot
var speed_check_cooldown := 1000 
var can_check_speed := true

func _ready() -> void:
	#We set the scaler as top level to ignore parent's transformations.
	#Otherwise, the camera will rotate violently.
	scaler.set_as_top_level(true)
	pass

#Checking if the golf ball is selected.
func _on_input_event(camera, event, position, normal, shape_idx) -> void:
	if event.is_action_pressed("left_mb"):
		if !is_shot:
			selected = true

func _input(event) -> void:
	#After the mouse is released, we calculate the speed and shoot the ball in the given direction.	
	if event.is_action_released("left_mb"):
		if selected:
			#Calculating the speed 
			speed = - (direction * distance * accel).limit_length(max_speed)
			
			shoot(speed)
			
			shoot_start_time = Time.get_ticks_msec()
			is_shot = true
			can_check_speed = false
			
		selected = false

func _process(delta) -> void:
	cooldowns()
	scaler_follow()
	
	pull_metter()
	
	#make the ball shootable if it's not moving only after a while of being shot
	if can_check_speed && !is_moving():
		print("reset by speed check")
		is_shot = false
	
#Shooting the golf ball.
func shoot(vector:Vector3)->void:
	velocity = Vector3(vector.x,0,vector.z)
	
	self.apply_impulse(velocity, Vector3.ZERO)
	
#Function to follow the golf ball.
func scaler_follow() -> void:
	scaler.transform.origin = scaler.transform.origin.lerp(self.transform.origin,.8)
	
func pull_metter() -> void:
	#Calling the raycast from the camera node.
	var ray_cast = camera_3d.camera_raycast()
	
	if not ray_cast.is_empty():
		#Calculating the distance between the golf ball and the mouse position.
		distance = self.position.distance_to(ray_cast.position)
		#Calculating the direction vector between golf ball ,and mouse position.
		direction = self.transform.origin.direction_to(ray_cast.position)
		#Looking at the mouse position in the 3D world.
		scaler.look_at(Vector3(ray_cast.position.x,position.y,ray_cast.position.z))
		
		if selected:
			#Scaling the scaler with limitation.
			scaler.scale.z = clamp(distance,0,2)
			
		else:
			#Resetting the scaler.
			scaler.scale.z = 0.01

func cooldowns():
	var current_time = Time.get_ticks_msec()
	var delta_shot = current_time - shoot_start_time
	
	if delta_shot >= shoot_cooldown_ms && is_shot:
		print("cooldown reset")
		is_shot = false
	if delta_shot >= speed_check_cooldown && !can_check_speed:
		print("can check speed")
		can_check_speed = true
		
func is_moving():
	return linear_velocity.length() > 0.2
