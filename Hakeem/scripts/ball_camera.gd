extends Camera3D

@onready var golf_ball = $".."

#Variables for raycast
const ray_length = 100
var mouse_pos : Vector2
var from :Vector3
var to : Vector3
var space : PhysicsDirectSpaceState3D
var query : PhysicsRayQueryParameters3D

#Variable for camera follow
var vector : Vector3

func _ready() -> void:
	#We set the camera as top level to ignore parent's transformations. 
	#Otherwise, the camera will rotate violently.
	self.set_as_top_level(true)
		
func _process(delta) -> void:
	#Function to follow golf ball.
	camera_follow()
	
#Function to follow golf ball.
func camera_follow() -> void:
	vector = Vector3(golf_ball.transform.origin.x,position.y,golf_ball.transform.origin.z)
	
	self.transform.origin = self.transform.origin.lerp(vector,0.2)
	
#Translating the mouse position from the screen into 3d world.
func camera_raycast():
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = project_ray_origin(mouse_pos)
	var ray_dir = project_ray_normal(mouse_pos)

	# Plane at the golf ball's height
	var plane = Plane(Vector3.UP, golf_ball.global_transform.origin.y)

	var hit_pos = plane.intersects_ray(ray_origin, ray_dir)

	if hit_pos:
		return { "position": hit_pos }

	return {}
