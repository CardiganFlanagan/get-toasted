extends Area2D

@export var amount: int  # сколько HP лечит, задаётся в heal.tscn


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.heal(amount)
		queue_free()
