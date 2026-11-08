class_name Bullet
extends Area2D
@export var speed := 250.0
@export var damage := 3
@export var life_time := 3.0

var direction := Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	life_time -= delta
	if life_time <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()
