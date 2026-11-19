extends Area2D

@export var ice_scene: PackedScene


func _on_tick_timeout() -> void:
	for body in get_overlapping_bodies():
		if not body.has_node("Ice"):
			body.add_child(ice_scene.instantiate())
