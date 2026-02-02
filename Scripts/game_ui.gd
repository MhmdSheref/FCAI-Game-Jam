extends CanvasLayer

# Game UI - Handles HUD, Win/Lose/Pause popups

@onready var shot_label: Label = $HUD/MarginContainer/HBoxContainer/ShotCounter
@onready var par_label: Label = $HUD/MarginContainer/HBoxContainer/ParLabel
@onready var win_panel: PanelContainer = $WinPanel
@onready var lose_panel: PanelContainer = $LosePanel
@onready var pause_panel: PanelContainer = $PausePanel
@onready var win_shots_label: Label = $WinPanel/VBoxContainer/ShotsLabel
@onready var win_message_label: Label = $WinPanel/VBoxContainer/MessageLabel

signal restart_requested
signal menu_requested
signal continue_requested

@export var par_value: int = 5
var current_shots: int = 0:
	set(value):
		current_shots = value
		_update_shot_display()

var is_paused: bool = false
var _escape_was_pressed: bool = false

func _ready() -> void:
	win_panel.visible = false
	lose_panel.visible = false
	pause_panel.visible = false
	_update_shot_display()
	
	# Connect to GameData if available
	if has_node("/root/GameData"):
		var game_data = get_node("/root/GameData")
		game_data.score_updated.connect(_on_score_updated)
		current_shots = game_data.get_current_shots()

func _process(_delta: float) -> void:
	# Handle Escape key for pause menu - check directly for key
	if Input.is_key_pressed(KEY_ESCAPE) and not _escape_was_pressed:
		_escape_was_pressed = true
		print("Escape key pressed! is_paused: ", is_paused)
		if is_paused:
			print("Resuming game...")
			_resume_game()
		elif not win_panel.visible and not lose_panel.visible:
			print("Pausing game...")
			_pause_game()
	elif not Input.is_key_pressed(KEY_ESCAPE):
		_escape_was_pressed = false

func _pause_game() -> void:
	print("_pause_game called")
	is_paused = true
	pause_panel.visible = true
	get_tree().paused = true

func _resume_game() -> void:
	print("_resume_game called")
	is_paused = false
	pause_panel.visible = false
	get_tree().paused = false

func _on_score_updated(shots: int) -> void:
	current_shots = shots

func _update_shot_display() -> void:
	if shot_label:
		shot_label.text = "Shots: %d" % current_shots
	if par_label:
		var diff = current_shots - par_value
		if diff <= -2:
			par_label.text = "Eagle!"
			par_label.modulate = Color.GOLD
		elif diff == -1:
			par_label.text = "Birdie!"
			par_label.modulate = Color.YELLOW
		elif diff == 0:
			par_label.text = "Par"
			par_label.modulate = Color.WHITE
		elif diff == 1:
			par_label.text = "Bogey"
			par_label.modulate = Color.ORANGE
		else:
			par_label.text = "+%d" % diff
			par_label.modulate = Color.RED

func show_win_screen() -> void:
	win_panel.visible = true
	
	# Update win message based on performance
	var diff = current_shots - par_value
	if diff <= -2:
		win_message_label.text = "🦅 EAGLE! Incredible!"
	elif diff == -1:
		win_message_label.text = "🐦 BIRDIE! Great shot!"
	elif diff == 0:
		win_message_label.text = "⛳ PAR! Well done!"
	elif diff == 1:
		win_message_label.text = "😅 Bogey, but you made it!"
	else:
		win_message_label.text = "🏌️ Hole complete!"
	
	win_shots_label.text = "Shots: %d" % current_shots
	
	# Pause game while showing win screen
	get_tree().paused = true

func show_lose_screen() -> void:
	lose_panel.visible = true
	get_tree().paused = true

func hide_popups() -> void:
	win_panel.visible = false
	lose_panel.visible = false
	pause_panel.visible = false
	is_paused = false
	get_tree().paused = false

# Win/Lose panel button handlers
func _on_continue_button_pressed() -> void:
	AudioManager.play_ui_click()
	hide_popups()
	continue_requested.emit()

func _on_restart_button_pressed() -> void:
	AudioManager.play_ui_click()
	hide_popups()
	if has_node("/root/GameData"):
		get_node("/root/GameData").reset_game()
	restart_requested.emit()

func _on_menu_button_pressed() -> void:
	AudioManager.play_ui_click()
	hide_popups()
	menu_requested.emit()

# Pause panel button handlers
func _on_pause_continue_pressed() -> void:
	AudioManager.play_ui_click()
	_resume_game()

func _on_pause_restart_pressed() -> void:
	AudioManager.play_ui_click()
	hide_popups()
	if has_node("/root/GameData"):
		get_node("/root/GameData").reset_game()
	get_tree().reload_current_scene()

func _on_pause_quit_pressed() -> void:
	AudioManager.play_ui_click()
	hide_popups()
	menu_requested.emit()
