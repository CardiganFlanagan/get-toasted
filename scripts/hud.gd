extends Control

@onready var pause_menu: Control = $"../pause_menu"
@onready var virtual_joystick: VirtualJoystick = $VirtualJoystick
@onready var crumbs_label: Label = $Crumbs/Label
@onready var plate_slots: Array[Node] = $Plate/Slots.get_children()


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		virtual_joystick.hide()


func _on_texture_button_pressed() -> void:
	pause_menu.open()


func refresh(crumbs: int, items: Array) -> void:
	crumbs_label.text = str(crumbs)
	for i in plate_slots.size():
		plate_slots[i].texture = items[i].icon if i < items.size() else null
