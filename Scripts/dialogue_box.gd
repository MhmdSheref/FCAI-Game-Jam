extends CanvasLayer

# Dialogue Box - Displays messages with optional character portraits
# Text animates letter-by-letter, auto-hides after duration

@onready var panel_container: PanelContainer = $PanelContainer
@onready var text_label: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/TextLabel
@onready var portrait_container: PanelContainer = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer
@onready var portrait: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer/Portrait
@onready var placeholder_bg: ColorRect = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer/PlaceholderBG
@onready var text_timer: Timer = $TextTimer
@onready var display_timer: Timer = $DisplayTimer

var full_text: String = ""
var current_char_index: int = 0
var is_displaying: bool = false

signal dialogue_finished

func _ready() -> void:
	# Hide initially
	panel_container.visible = false

func show_dialogue(text: String, portrait_texture: Texture2D = null, duration: float = 0.0, custom_box_texture: Texture2D = null) -> void:
	"""
	Display a dialogue message with optional portrait.
	
	Args:
		text: The message to display
		portrait_texture: Optional character portrait (null = show placeholder)
		duration: How long to show after text finishes (0 = wait for manual dismiss)
		custom_box_texture: Optional custom dialogue box texture (not implemented yet)
	"""
	full_text = text
	current_char_index = 0
	is_displaying = true
	
	# Setup text
	text_label.text = ""
	text_label.visible_characters = 0
	
	# Setup portrait
	if portrait_texture:
		portrait.texture = portrait_texture
		portrait.visible = true
		placeholder_bg.visible = false
	else:
		portrait.visible = false
		placeholder_bg.visible = true
	
	# Show panel and start text animation
	panel_container.visible = true
	text_label.text = full_text
	text_timer.start()

func _on_text_timer_timeout() -> void:
	if current_char_index < full_text.length():
		current_char_index += 1
		text_label.visible_characters = current_char_index
	else:
		# Text finished
		text_timer.stop()
		_on_text_complete()

func _on_text_complete() -> void:
	# If display timer was set, start countdown
	if display_timer.wait_time > 0:
		display_timer.start()

func _on_display_timer_timeout() -> void:
	hide_dialogue()

func hide_dialogue() -> void:
	panel_container.visible = false
	is_displaying = false
	text_timer.stop()
	display_timer.stop()
	dialogue_finished.emit()

func skip_animation() -> void:
	"""Skip to showing full text immediately"""
	if is_displaying and current_char_index < full_text.length():
		current_char_index = full_text.length()
		text_label.visible_characters = current_char_index
		text_timer.stop()
		_on_text_complete()

func _input(event: InputEvent) -> void:
	# Click or press to skip/dismiss
	if is_displaying and event.is_action_pressed("left_mb"):
		if current_char_index < full_text.length():
			skip_animation()
		else:
			hide_dialogue()

func set_display_duration(duration: float) -> void:
	display_timer.wait_time = duration

func set_text_speed(chars_per_second: float) -> void:
	text_timer.wait_time = 1.0 / chars_per_second
