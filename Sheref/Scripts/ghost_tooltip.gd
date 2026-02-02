extends Panel
@onready var label: Label = $VBoxContainer/PanelContainer/MarginContainer/Label
@onready var rich_text_label: RichTextLabel = $VBoxContainer/MarginContainer/RichTextLabel

var ghost_type = "pull_ghost"
var last_ghost_type = "pull_ghost"
var was_visible_before_dialog: bool = false

const ghost_data = {
	"pull_ghost": {"name": "Pull Ghost 🧲", "description": "This ghost pulls your ball towards its center when you're within range. Great for guiding shots around corners."},
	"push_ghost": {"name": "Push Ghost 💨", "description": "This ghost pushes your ball away from its center when you're within range. Use it to add power to your shots."},
	"bounce_ghost": {"name": "Bounce Ghost 🦘", "description": "This ghost launches your ball upward when you enter its area. Perfect for reaching elevated platforms!"},
	"slow_ghost": {"name": "Slow Ghost 🐌", "description": "This ghost reduces your ball's speed when inside its area. Use it for precision shots near the hole."},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ghost_data[ghost_type]["name"]
	rich_text_label.text = ghost_data[ghost_type]["description"]
	
	# Connect to dialogue events to hide/show panel (same as ghost_selector)
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ghost_type != last_ghost_type:
		last_ghost_type = ghost_type
		label.text = ghost_data[ghost_type]["name"]
		rich_text_label.text = ghost_data[ghost_type]["description"]

func _on_dialogue_requested(_text: String, _portrait: Texture2D, _duration: float) -> void:
	was_visible_before_dialog = visible
	visible = false

func _on_dialogue_finished() -> void:
	# Only restore visibility if we were visible before AND we should be showing UI
	var game_manager = get_node_or_null("%GameManager")
	if game_manager and game_manager.is_intro_complete():
		visible = was_visible_before_dialog
	elif was_visible_before_dialog:
		visible = was_visible_before_dialog
