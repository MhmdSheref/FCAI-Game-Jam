extends Camera3D

@onready var golf_ball: RigidBody3D = $"../.."

#camera script only needs raycast without any ball following logic, since it follows the camera pivot
func camera_raycast():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_dir = project_ray_normal(mouse_pos)
	
	#use ball's y coordinate as the projection plane for raycasting
	var plane = Plane(Vector3.UP, golf_ball.global_transform.origin.y)
	
	#the position where the camera ray instersects the ball's XZ-plane
	var hit_pos = plane.intersects_ray(ray_origin, ray_dir)

	if hit_pos:
		return { "position": hit_pos }

	return {}
