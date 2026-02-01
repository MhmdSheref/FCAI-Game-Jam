extends Panel
@onready var label: Label = $VBoxContainer/PanelContainer/MarginContainer/Label
@onready var rich_text_label: RichTextLabel = $VBoxContainer/MarginContainer/RichTextLabel

var ghost_type = "pull_ghost"
var last_ghost_type = "pull_ghost"
const ghost_data = {
	"pull_ghost": {"name": "Pull Ghost", "description": "This ghost pulls your ball towards from its center when you're within range"},
	"push_ghost": {"name": "Push Ghost", "description": "This ghost pushes your ball away its center when you're withing range"},
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ghost_data[ghost_type]["name"]
	rich_text_label.text = ghost_data[ghost_type]["description"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ghost_type != last_ghost_type:
		last_ghost_type = ghost_type
		label.text = ghost_data[ghost_type]["name"]
		rich_text_label.text = ghost_data[ghost_type]["description"]

		
	pass
