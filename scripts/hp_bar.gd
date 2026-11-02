class_name HPBar
extends Control

@export_range(0.0, 1.0) var low_hp := 0.3

const RED := Color("ff424f")
const GREEN := Color("afe356")

@onready var trail: TextureProgressBar = $hp/trail
@onready var jam: TextureProgressBar = $hp/jam
@onready var front: TextureRect = $hp/front
@onready var shine: TextureRect = $hp/shine
@onready var badge: TextureRect = $badge
@onready var value_label: Label = $value

var _hp := -1
var _max_hp := 1
var _badge_home: Vector2

var _bar_tween: Tween
var _shake_tween: Tween
var _blink_tween: Tween


func _ready() -> void:
	_badge_home = badge.position
	jam.value_changed.connect(_on_jam_value_changed)
	_start_shine()
	if get_tree().current_scene == self:
		set_health(25, 25)
	else:
		_connect_to_player.call_deferred()


func _connect_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.hp_changed.connect(set_health)
		set_health(player.hp, player.max_hp)


func set_health(hp: int, max_hp: int) -> void:
	hp = clampi(hp, 0, max_hp)
	var old := _hp
	_hp = hp
	_max_hp = max_hp
	jam.max_value = max_hp
	trail.max_value = max_hp
	value_label.text = "%d / %d" % [hp, max_hp]
	_update_blink()

	if old < 0:  # первый вызов — без анимации
		jam.value = hp
		trail.value = hp
		_on_jam_value_changed(hp)
	elif hp < old:
		_play_damage(hp)
	elif hp > old:
		_play_heal(hp)


func _play_damage(hp: int) -> void:
	if _bar_tween: _bar_tween.kill()
	_bar_tween = create_tween().set_parallel()
	_bar_tween.tween_property(jam, "value", float(hp), 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_bar_tween.tween_property(trail, "value", float(hp), 0.35).set_delay(0.3) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_flash(RED, 0.12)
	_pop_value()
	_shake_badge()


func _play_heal(hp: int) -> void:
	if _bar_tween: _bar_tween.kill()
	trail.value = jam.value
	_bar_tween = create_tween().set_parallel() \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_bar_tween.tween_property(jam, "value", float(hp), 0.4)
	_bar_tween.tween_property(trail, "value", float(hp), 0.4)
	_flash(GREEN, 0.25)
	_pop_value()


func _on_jam_value_changed(v: float) -> void:
	front.visible = v > 0.0
	front.position.x = roundf(jam.size.x * jam.ratio)


func _pop_value() -> void:
	value_label.pivot_offset = value_label.size / 2
	value_label.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(value_label, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _flash(color: Color, time: float) -> void:
	if not _blink_tween:  # пока мигает, не перекрашиваем
		create_tween().tween_property(value_label, "modulate", Color.WHITE, time).from(color)


func _update_blink() -> void:
	var low := float(_hp) / maxi(_max_hp, 1) < low_hp
	if low and not _blink_tween:
		_blink_tween = create_tween().set_loops()
		_blink_tween.tween_property(value_label, "modulate", RED, 0.3)
		_blink_tween.tween_property(value_label, "modulate", Color.WHITE, 0.3)
	elif not low and _blink_tween:
		_blink_tween.kill()
		_blink_tween = null
		value_label.modulate = Color.WHITE


func _shake_badge() -> void:
	if _shake_tween: _shake_tween.kill()
	badge.position = _badge_home
	_shake_tween = create_tween()
	for dx in [2, -2, 1, -1, 0]:
		_shake_tween.tween_property(badge, "position:x", _badge_home.x + dx, 0.04)


func _start_shine() -> void:
	var t := create_tween().set_loops()
	t.tween_property(shine, "position:x", 110.0, 0.6).from(-8.0)
	t.tween_interval(4.0)


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().current_scene != self or not event is InputEventKey or not event.pressed:
		return
	if event.keycode == KEY_1: set_health(_hp - 3, _max_hp)
	if event.keycode == KEY_2: set_health(_hp + 5, _max_hp)
