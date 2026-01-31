class_name Ghost
extends StaticBody3D

enum ForceType{
	Push,
	Pull,
}

@export var force_power := 1.0
@export var force_type := ForceType.Push

func get_force():
	match(force_type):
		ForceType.Push:
			return force_power;		
		ForceType.Pull:
			return -force_power;
