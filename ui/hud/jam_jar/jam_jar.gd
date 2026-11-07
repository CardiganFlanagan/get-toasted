class_name JamJar
extends Control

## Банка опустела (значение дошло до 0).
signal emptied
@onready var value: Label = $Visual/value

enum Flavor { STRAWBERRY, APRICOT, BLUEBERRY }

## Цвета варенья: основной, светлая кромка, тень и крупные ягоды, «призрачный» уровень, косточки.
## Новый вкус = новая строка здесь, новое имя в enum Flavor и новый кадр бирки в jam_jar_tag.png.
const FLAVORS := {
	Flavor.STRAWBERRY: {"jam": Color("d33a4f"), "light": Color("f2788a"), "dark": Color("8f1f33"), "ghost": Color("f0aab5"), "seed": Color("ffd36b")},
	Flavor.APRICOT: {"jam": Color("ee8f2c"), "light": Color("ffc46b"), "dark": Color("b0581a"), "ghost": Color("f7d1a1"), "seed": Color("fff0c4")},
	Flavor.BLUEBERRY: {"jam": Color("6a4bb8"), "light": Color("9a83e0"), "dark": Color("33236b"), "ghost": Color("c9bcef"), "seed": Color("c3b4f5")},
}

# Кадры в jam_jar_face.png (слева направо).
const FACE_NORMAL := 0
const FACE_BLINK := 1
const FACE_ALERT := 2
const FACE_ALERT_BLINK := 3
const FACE_HIT := 4
const FACE_DEAD := 5

## Вкус варенья.
@export var flavor: Flavor = Flavor.BLUEBERRY:
	set(v):
		flavor = v
		if is_node_ready():
			_apply_flavor()
@export var max_value := 100.0
@export_range(0.0, 1.0) var start_fill := 1.0
@export_range(0.0, 1.0) var alert_threshold := 0.25

@export_group("Ощущения")
@export var heal_speed := 0.8
@export var ghost_delay := 0.7
@export var ghost_speed := 0.35
@export var shake_time := 0.35
@export var dead_tint := Color(0.55, 0.55, 0.6)

@onready var _visual: Control = $Visual
@onready var _face: Sprite2D = $Visual/Face
@onready var _front: TextureRect = $Visual/Front
@onready var _tag: Sprite2D = $Visual/Tag
@onready var _mat: ShaderMaterial = ($Visual/Jam as ColorRect).material as ShaderMaterial

var _value := 100.0
var _target := 1.0     
var _shown := 1.0      
var _ghost := 1.0      
var _ghost_wait := 0.0
var _since_hit := 99.0
var _shake := 0.0
var _flash := 0.0
var _running := false
var _slosh := 0.0
var _dead_fade := 0.0
var _t := 0.0


func _ready() -> void:
	_apply_flavor()
	_value = start_fill * max_value
	_target = start_fill
	_shown = start_fill
	_ghost = start_fill


func set_value(new_value: float, new_max: float = max_value) -> void:
	max_value = maxf(new_max, 0.001)
	_value = clampf(new_value, 0.0, max_value)
	var new_target := _value / max_value
	if new_target < _target - 0.0001:
		_ghost = maxf(_ghost, _shown)
		_shown = new_target
		_ghost_wait = ghost_delay
		_since_hit = 0.0
		_shake = shake_time
		if new_target <= 0.0:
			emptied.emit()
	elif new_target > _target + 0.0001:
		_flash = 1.0
	_target = new_target
	value.text = "%d / %d" % [_value, max_value]


func get_value() -> float:
	return _value


func set_running(on: bool) -> void:
	_running = on


func refill() -> void:
	_value = max_value
	_target = 1.0
	_shown = 1.0
	_ghost = 1.0
	_ghost_wait = 0.0


func _apply_flavor() -> void:
	var f: Dictionary = FLAVORS[flavor]
	_mat.set_shader_parameter("jam_color", f["jam"])
	_mat.set_shader_parameter("jam_light_color", f["light"])
	_mat.set_shader_parameter("jam_dark_color", f["dark"])
	_mat.set_shader_parameter("ghost_color", f["ghost"])
	_mat.set_shader_parameter("seed_color", f["seed"])
	_tag.frame = mini(int(flavor), _tag.hframes - 1)


func _process(delta: float) -> void:
	_t += delta
	_since_hit += delta
	_shake = maxf(_shake - delta, 0.0)
	_flash = maxf(_flash - delta * 3.0, 0.0)

	if _shown < _target:
		_shown = minf(_target, _shown + delta * heal_speed)
	_ghost = maxf(_ghost, _shown)
	if _ghost_wait > 0.0:
		_ghost_wait -= delta
	elif _ghost > _shown:
		_ghost = maxf(_shown, _ghost - delta * ghost_speed)
	_slosh = lerpf(_slosh, 1.0 if _running else 0.0, minf(1.0, delta * 3.0))

	var dead := _target <= 0.0
	var alert := not dead and _shown <= alert_threshold
	_dead_fade = move_toward(_dead_fade, 1.0 if dead else 0.0, delta * 2.0)

	_mat.set_shader_parameter("height", _shown)
	_mat.set_shader_parameter("oheight", _ghost)
	_mat.set_shader_parameter("wobble", exp(-_since_hit * 3.0))
	_mat.set_shader_parameter("slosh", _slosh)
	_mat.set_shader_parameter("flash", _flash)
	_mat.set_shader_parameter("alert", alert)
	_mat.set_shader_parameter("gray_amount", _dead_fade)
	_front.modulate = Color.WHITE.lerp(dead_tint, _dead_fade)
	_tag.modulate = _front.modulate

	if _shake > 0.0:
		_visual.position = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	else:
		_visual.position = Vector2.ZERO

	var blink := fmod(_t, 3.2) < 0.12
	if dead:
		_face.frame = FACE_DEAD
	elif _shake > 0.0:
		_face.frame = FACE_HIT
	elif alert:
		_face.frame = FACE_ALERT_BLINK if blink else FACE_ALERT
	else:
		_face.frame = FACE_BLINK if blink else FACE_NORMAL

func _pop_value() -> void:
	value.pivot_offset = value.size / 2
	value.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(value, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
