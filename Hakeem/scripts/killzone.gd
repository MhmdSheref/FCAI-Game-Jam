extends Area3D

@onready var timer: Timer = $Timer

signal death

func _on_body_entered(body: Node3D) -> void:
	if body is GolfBall:
		timer.start()
		


func _on_timer_timeout() -> void:
	death.emit()
