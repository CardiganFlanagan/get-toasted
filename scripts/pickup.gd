class_name Pickup
extends Area2D

@export var magnet_range := 90.0
@export var speed := 260.0

var amount := 1
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if global_position.distance_to(player.global_position) < magnet_range:
		global_position = global_position.move_toward(player.global_position, speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.get_node("Plate").add_crumbs(amount)
		queue_free()
