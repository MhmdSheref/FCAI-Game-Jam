extends Area3D

@onready var ghost: Ghost = $".."

var force_vector: Vector3

func apply_forces():
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			print("applied force")
			force_vector = body.position - ghost.position
			body.apply_force(force_vector.normalized()*ghost.get_force())
	
func _physics_process(delta: float) -> void:
	apply_forces()
