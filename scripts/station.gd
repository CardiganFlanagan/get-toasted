extends Area2D

@warning_ignore("unused_signal")
signal opened
signal closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("stand")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("RESET")
		closed.emit()
