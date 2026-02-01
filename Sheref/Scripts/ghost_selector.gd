extends PanelContainer
@onready var button: TextureButton = $VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/HBoxContainer/PanelContainer/pull_ghost
signal changed_ghost_selection(button_name : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_group.pressed.connect(changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func changed(button: BaseButton):
	print(button.name)
	changed_ghost_selection.emit(button.name)
