extends PanelContainer
@onready var button: TextureButton = $VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/HBoxContainer/PanelContainer/pull_ghost
@onready var ghost_buttons_container: HBoxContainer = $VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/HBoxContainer
signal changed_ghost_selection(button_name : String)

var ghost_buttons: Array[BaseButton] = []
var current_ghost_index: int = 0
var was_visible_before_dialog: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_group.pressed.connect(changed)
	
	# Collect all ghost buttons from the container
	for panel in ghost_buttons_container.get_children():
		if panel is PanelContainer:
			for child in panel.get_children():
				if child is TextureButton:
					ghost_buttons.append(child)
	
	# Connect to EventBus signals for Q/E switching
	EventBus.switch_ghost_left_requested.connect(_on_switch_ghost_left)
	EventBus.switch_ghost_right_requested.connect(_on_switch_ghost_right)
	
	# Connect to dialogue events to hide/show panel
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_requested(_text: String, _portrait: Texture2D, _duration: float) -> void:
	was_visible_before_dialog = visible
	visible = false

func _on_dialogue_finished() -> void:
	# Only restore visibility if we're still in freecam state
	var freecam = get_node_or_null("%Freecam3D")
	if freecam and freecam.movement_active:
		visible = was_visible_before_dialog

func _on_switch_ghost_left() -> void:
	if ghost_buttons.size() == 0:
		return
	current_ghost_index = (current_ghost_index - 1 + ghost_buttons.size()) % ghost_buttons.size()
	_select_ghost_at_index(current_ghost_index)

func _on_switch_ghost_right() -> void:
	if ghost_buttons.size() == 0:
		return
	current_ghost_index = (current_ghost_index + 1) % ghost_buttons.size()
	_select_ghost_at_index(current_ghost_index)

func _select_ghost_at_index(index: int) -> void:
	if index >= 0 and index < ghost_buttons.size():
		ghost_buttons[index].button_pressed = true
		changed(ghost_buttons[index])

func changed(button: BaseButton):
	# Update current index when button is clicked directly
	for i in range(ghost_buttons.size()):
		if ghost_buttons[i] == button:
			current_ghost_index = i
			break
	print(button.name)
	changed_ghost_selection.emit(button.name)
