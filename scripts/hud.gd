extends Control


@onready var pause_menu: Control = $"../pause_menu"
@onready var virtual_joystick: VirtualJoystick = $VirtualJoystick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		virtual_joystick.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	pause_menu.visible = true
	get_tree().paused = true
