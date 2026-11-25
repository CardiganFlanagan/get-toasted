extends Node

var enabled := true
var shake_tween: Tween


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_J:
		enabled = not enabled
		get_tree().call_group("juice", "set_visible", enabled)


func _on_node_added(node: Node) -> void:
	if node is CanvasItem and node.is_in_group("juice"):
		node.visible = enabled


func spawn(scene: PackedScene, at: Vector2) -> Node2D:
	var effect: Node2D = scene.instantiate()
	effect.position = at
	get_tree().current_scene.add_child.call_deferred(effect)
	return effect


func flash(sprite: CanvasItem) -> void:
	if enabled:
		sprite.create_tween().tween_property(sprite, "material:shader_parameter/flash", 0.0, 0.12).from(1.0)


func shake(strength: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if not enabled or strength <= 0 or camera == null:
		return
	if shake_tween:
		shake_tween.kill()
	shake_tween = camera.create_tween()
	for i in 4:
		shake_tween.tween_property(camera, "offset", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength, 0.03)
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.03)


func hit_stop(time: float) -> void:
	if not enabled:
		return
	Engine.time_scale = 0.0
	await get_tree().create_timer(time, true, false, true).timeout
	Engine.time_scale = 1.0
