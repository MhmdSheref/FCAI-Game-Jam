extends Control

# Game End Screen - Shows after completing all levels

func _ready() -> void:
	# Play a victory sound if available
	if AudioManager:
		AudioManager.play_win()

func _on_return_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
