extends CSGBox3D


# Building.gd
func set_as_ghost(is_ghost: bool):
	if is_ghost:
		# Lower alpha on the mesh (Requires material to be 'Transparent' or 'Depth Draw: Always')
		# This assumes you have a MeshInstance3D as a child
		transparency = 0.5 
		# Disable collisions so the ghost doesn't block the raycast
		use_collision = false
	else:
		transparency = 0.0
		use_collision = true
