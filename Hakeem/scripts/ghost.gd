class_name Ghost
extends StaticBody3D

enum ForceType{
	Push,
	Pull,
}

@export var force_power := 1.0
@export var force_type := ForceType.Push
@export var lateral_effect := true
@export var infinite_effect := false
@export var effect_cooldown := 1.0

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
	
