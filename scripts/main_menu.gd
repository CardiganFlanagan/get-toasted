extends Control

@onready var texture_button: TextureButton = $TextureButton
@onready var animated_sprite_2d: AnimatedSprite2D = $TextureButton/AnimatedSprite2D
@onready var sfx: AudioStreamPlayer2D = $TextureButton/SFX
@onready var level_buttons: Array[Node] = $Levels.get_children()
@onready var best_time: Label = $BestTime
@onready var volume: HSlider = $Settings/Volume
@onready var texture_button_2: TextureButton = $TextureButton2
@onready var animated_sprite_2d_2: AnimatedSprite2D = $TextureButton2/AnimatedSprite2D2


func _ready() -> void:
	# закрытые уровни нельзя выбрать
	for i in level_buttons.size():
		level_buttons[i].disabled = i >= Game.data.unlocked
	level_buttons[Game.level_index].button_pressed = true
	best_time.text = "Рекорд: %d" % Game.data.best_score
	volume.value = Game.volume


func _on_texture_button_pressed() -> void:
	texture_button.disabled = true
	animated_sprite_2d.show()
	animated_sprite_2d.play()
	sfx.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


# Табличка «ВЫХОД»: переворачивается на «ЗАКРЫТО», потом игра закрывается
func _on_texture_button_2_pressed() -> void:
	texture_button_2.disabled = true
	texture_button_2.self_modulate.a = 0
	animated_sprite_2d_2.show()
	animated_sprite_2d_2.frame = 0
	animated_sprite_2d_2.play()


func _on_animated_sprite_2d_2_animation_finished() -> void:
	Game.save_progress()
	get_tree().quit()


func _on_level_pressed(index: int) -> void:
	Game.level_index = index


func _on_volume_value_changed(value: float) -> void:
	Game.set_volume(value)


func _on_volume_drag_ended(_value_changed: bool) -> void:
	Game.save_settings()  # сохраняем, когда игрок отпустил ползунок


func _on_reset_dialog_confirmed() -> void:
	Game.reset_progress()
	get_tree().reload_current_scene()
