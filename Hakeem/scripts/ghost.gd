class_name Ghost
extends StaticBody3D

enum ForceType{
	Push,
	Pull,
}

@onready var mesh_instance_3d: MeshInstance3D = $ghost/Ghost
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var force_power := 8.0
@export var force_type := ForceType.Push
@export var lateral_effect := true
@export var infinite_effect := false
@export var effect_cooldown := 1.0

var _is_ghost:= true

func get_force():
	match(force_type):
		ForceType.Push:
			return force_power;		
		ForceType.Pull:
			return -force_power;
			
func affect_body(body: RigidBody3D):
	var force_vector = body.position - position
	if lateral_effect:
		force_vector = force_vector - Vector3(0, force_vector.y, 0) #remove y component to avoid ball jumping
	body.apply_impulse(force_vector.normalized()*get_force())
	
func set_as_ghost(is_ghost: bool):
	_is_ghost = is_ghost
	if _is_ghost:
		# Lower alpha on the mesh (Requires material to be 'Transparent' or 'Depth Draw: Always')
		# This assumes you have a MeshInstance3D as a child
		mesh_instance_3d.transparency = 0.5 
		# Disable collisions so the ghost doesn't block the raycast
		collision_shape_3d.disabled = true
	else:
		mesh_instance_3d.transparency = 0.0
		collision_shape_3d.disabled = false
	
