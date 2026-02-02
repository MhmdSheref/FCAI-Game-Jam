extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var leaderboard_button: Button = $CenterContainer/VBoxContainer/LeaderboardButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var leaderboard_panel: PanelContainer = $LeaderboardPanel
@onready var back_button: Button = $LeaderboardPanel/VBoxContainer/BackButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Hide leaderboard panel initially
	leaderboard_panel.visible = false
	
	# Play subtle animation on menu appearance
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_play_pressed() -> void:
	AudioManager.play_ui_click()
	# Fade out and change scene
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://Hakeem/scenes/fullLevelTest.tscn"))

func _on_leaderboard_pressed() -> void:
	AudioManager.play_ui_click()
	leaderboard_panel.visible = true
	_populate_leaderboard()

func _on_back_pressed() -> void:
	AudioManager.play_ui_click()
	leaderboard_panel.visible = false

func _on_quit_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().quit()

func _populate_leaderboard() -> void:
	var scores_container = $LeaderboardPanel/VBoxContainer/ScrollContainer/ScoresContainer
	
	# Clear existing scores
	for child in scores_container.get_children():
		child.queue_free()
	
	# Get scores from GameData if it exists
	var scores = []
	if Engine.has_singleton("GameData"):
		scores = GameData.get_high_scores()
	else:
		# Default placeholder scores
		scores = [
			{"name": "ACE", "shots": 3},
			{"name": "PRO", "shots": 5},
			{"name": "---", "shots": 0},
		]
	
	# Populate leaderboard
	for i in range(min(scores.size(), 10)):
		var score_entry = scores[i]
		var label = Label.new()
		label.text = "%d. %s - %d shots" % [i + 1, score_entry.name, score_entry.shots]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scores_container.add_child(label)
