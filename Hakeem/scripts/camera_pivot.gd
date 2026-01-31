extends Node3D

@onready var golf_ball: RigidBody3D = $".."

@export var sensitivity := 0.005
@export var zoom_speed := 2.0
@export var min_zoom := 2.0
@export var max_zoom := 15.0

var pitch := -0.3
var yaw := 0.0

func _ready() -> void:
	self.set_as_top_level(true)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		#apply yaw and pitch changes if right mouse button is pressed
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): 
			yaw -= event.relative.x * sensitivity
			pitch -= event.relative.y * sensitivity
			pitch = clamp(pitch, -1.2, -0.1)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom(-zoom_speed)

func _process(delta: float):
	global_position = golf_ball.global_position
	rotation.y = yaw
	rotation.x = pitch

func zoom(amount: float):
	var cam = $Camera3D
	cam.position.z -= amount
	cam.position.z = clamp(cam.position.z, min_zoom, max_zoom)
