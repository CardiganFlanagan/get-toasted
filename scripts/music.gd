extends Node

const FADE_TIME := 1.0
const PAUSED_CUTOFF := 700.0
const PAUSED_DB := -8.0

var current: AudioStreamPlayer
var tween: Tween

@onready var a: AudioStreamPlayer = $A
@onready var b: AudioStreamPlayer = $B
@onready var bus := AudioServer.get_bus_index(&"Music")
@onready var lowpass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(bus, 0)
@onready var amplify: AudioEffectAmplify = AudioServer.get_bus_effect(bus, 1)


func play(stream: AudioStream) -> void:
	if current and current.stream == stream:
		return
	var old := current
	current = b if current == a else a
	current.stream = stream
	current.volume_linear = 0.0
	current.play()
	if tween:
		tween.kill()
	tween = create_tween().set_parallel()
	tween.tween_property(current, "volume_linear", 1.0, FADE_TIME)
	if old:
		tween.tween_property(old, "volume_linear", 0.0, FADE_TIME)
		tween.chain().tween_callback(old.stop)


func _process(delta: float) -> void:
	var k := minf(delta * 5.0, 1.0)
	var paused := get_tree().paused
	lowpass.cutoff_hz = lerpf(lowpass.cutoff_hz, PAUSED_CUTOFF if paused else 20000.0, k)
	amplify.volume_db = lerpf(amplify.volume_db, PAUSED_DB if paused else 0.0, k)
