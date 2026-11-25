class_name Bullet
extends Area2D

var speed: float
var damage: int
var direction := Vector2.RIGHT

@export var life_time: float
@export var target_group: StringName
@export var blast_radius: float
@export var hit_effect: PackedScene
@export var pierce := 0
@export var spin := 0.0
@export var shake := 0.0


func _ready() -> void:
	body_entered.connect(hit)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += spin * delta
	life_time -= delta
	if life_time <= 0:
		hit(null)


func hit(body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	if blast_radius > 0:
		for node in get_tree().get_nodes_in_group(target_group):
			if global_position.distance_to(node.global_position) < blast_radius:
				node.take_damage(damage)
	elif body and body.is_in_group(target_group):
		body.take_damage(damage)
		if pierce > 0:
			pierce -= 1
			return
	Juice.shake(shake)
	if hit_effect:
		var effect: Node2D = hit_effect.instantiate()
		effect.position = global_position
		get_parent().add_child.call_deferred(effect)
	queue_free()
