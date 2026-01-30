extends Camera3D

@onready var golf_ball: RigidBody3D = $"../.."

const ray_length = 100

func camera_raycast():
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = project_ray_origin(mouse_pos)
	var ray_dir = project_ray_normal(mouse_pos)

	var plane = Plane(Vector3.UP, golf_ball.global_transform.origin.y)

	var hit_pos = plane.intersects_ray(ray_origin, ray_dir)

	if hit_pos:
		return { "position": hit_pos }

	return {}
