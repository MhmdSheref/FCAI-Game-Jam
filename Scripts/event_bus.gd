extends Node

# Event Bus - Global signal dispatcher for decoupled communication
# Add this as an autoload in Project Settings

# Ghost Events
signal ghost_force_applied(ghost_type: int, force_power: float)
signal ghost_placed(ghost_type: int, position: Vector3)
signal ghost_removed(position: Vector3)

# Ball Events
signal ball_shot(velocity: Vector3)
signal ball_stopped()
signal ball_entered_hole()
signal ball_out_of_bounds()

# Game Events
signal game_started()
signal game_paused()
signal game_resumed()
signal level_completed(shots: int)

# Dialogue Events
signal dialogue_requested(text: String, portrait: Texture2D, duration: float)
signal dialogue_finished()

# Helper functions for common events
func emit_ghost_force(ghost_type: int, force_power: float) -> void:
	ghost_force_applied.emit(ghost_type, force_power)

func emit_dialogue(text: String, portrait: Texture2D = null, duration: float = 0.0) -> void:
	dialogue_requested.emit(text, portrait, duration)
