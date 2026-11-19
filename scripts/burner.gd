extends Area2D

@export var damage := 3


func _on_tick_timeout() -> void:
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
