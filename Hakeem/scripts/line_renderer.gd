class_name LineRenderer
extends Node3D

@onready var ball: GolfBall = $".."
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var line: Curve3D

@export var sample_distance:= 0.5
@export var max_points:= 300


var sampled_points: Array[Vector3]
var last_sample_pos: Vector3
var sampling := false

func _ready() -> void:
	self.set_as_top_level(true)
	self.global_position = Vector3.ZERO
	self.global_rotation = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not sampling:
		return
		
	sample_if_needed()

func sample_if_needed():
	var current_pos = ball.global_position

	if sampled_points.is_empty():
		sampled_points.append(current_pos)
		last_sample_pos = current_pos
		return

	if current_pos.distance_to(last_sample_pos) >= sample_distance:
		sampled_points.append(current_pos)
		last_sample_pos = current_pos
		
		if sampled_points.size() > max_points:
			sampled_points.remove_at(0)
	
func build_mesh():
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)

	for i in range(sampled_points.size() - 1):
		im.surface_add_vertex(sampled_points[i])
		im.surface_add_vertex(sampled_points[i + 1])

	im.surface_end()
	mesh_instance_3d.mesh = im

func _on_ball_just_shot() -> void:
	sampling = true
	mesh_instance_3d.mesh = null
	sampled_points.clear()

func _on_ball_shot_ended() -> void:
	sampling = false
	if sampled_points.size() >= 2:
		build_mesh()
