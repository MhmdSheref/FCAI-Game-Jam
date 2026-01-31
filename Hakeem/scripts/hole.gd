extends Area3D

signal ball_entered

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is GolfBall:
			ball_entered.emit()
