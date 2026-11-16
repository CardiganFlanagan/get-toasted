class_name Bullet
extends Area2D

var speed: float
var damage: int
var direction := Vector2.RIGHT

@export var life_time: float
@export var target_group: StringName


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	life_time -= delta
	if life_time <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		body.take_damage(damage)
	queue_free()
