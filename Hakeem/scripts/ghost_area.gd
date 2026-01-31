extends Area3D

@onready var ghost: Ghost = $".."

var force_vector: Vector3
var affected_bodies = []

var effect_start_time : int
var can_affect := true

func apply_forces():
	if can_affect:
		for body in get_overlapping_bodies():
			if body is RigidBody3D && not body in affected_bodies:
				print("applied force")
				if !ghost.infinite_effect:
					affected_bodies.append(body)
				force_vector = body.position - ghost.position
				force_vector = force_vector - Vector3(0, force_vector.y, 0) #remove y component to avoid ball jumping
				body.apply_impulse(force_vector.normalized()*ghost.get_force())
				
				effect_start_time = Time.get_ticks_msec()
				can_affect = false
	
func _physics_process(delta: float) -> void:
	apply_forces()
	cooldowns()

func cooldowns():
	var current_time = Time.get_ticks_msec()
	var delta_effect = current_time - effect_start_time
	
	if delta_effect >= ghost.effect_cooldown*1000 && !can_affect: #(*1000): sec->ms
		can_affect = true
		print("effect reset")
