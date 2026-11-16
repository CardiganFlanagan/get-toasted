extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var bell: TextureButton = $Board/Bell


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if not visible and not get_tree().paused:
		open()
	elif visible and not bell.disabled:
		anim.play("ring")


func open() -> void:
	get_tree().paused = true
	show()
	anim.play("open")
	anim.advance(0)


func _resume() -> void:
	hide()
	get_tree().paused = false


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
