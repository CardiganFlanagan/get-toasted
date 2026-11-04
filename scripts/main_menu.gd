extends Control

@onready var texture_button: TextureButton = $TextureButton
@onready var animated_sprite_2d: AnimatedSprite2D = $TextureButton/AnimatedSprite2D
@onready var sfx: AudioStreamPlayer2D = $TextureButton/SFX


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	texture_button.disabled = true
	animated_sprite_2d.show()
	animated_sprite_2d.play()
	sfx.play()
	#await animated_sprite_2d.animation_finished


func _on_animated_sprite_2d_animation_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")
