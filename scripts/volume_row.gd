extends HBoxContainer

@export var title := "Музыка"
@export var setting := "music"

@onready var cups: Array[Node] = $Cups.get_children()


func _ready() -> void:
	$Title.text = title
	show_level()


func _on_cup_pressed(index: int) -> void:
	var old: int = Game.data[setting]
	var level := 0 if index + 1 == old else index + 1
	Game.set_volume(setting, level)
	show_level()
	for i in cups.size():
		if (i < level) != (i < old):
			pop(cups[i])
	$Clink.pitch_scale = 1.25 - index * 0.2
	$Clink.play()


func show_level() -> void:
	for i in cups.size():
		cups[i].set_pressed_no_signal(i < Game.data[setting])


func pop(cup: Control) -> void:
	create_tween().tween_property(cup, "scale", Vector2.ONE, 0.3).from(Vector2(1.35, 1.35)) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
