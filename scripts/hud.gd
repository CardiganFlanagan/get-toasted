extends Control

@onready var pause_menu: Control = $"../pause_menu"
@onready var virtual_joystick: VirtualJoystick = $VirtualJoystick


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		virtual_joystick.hide()


func _on_texture_button_pressed() -> void:
	pause_menu.open()
