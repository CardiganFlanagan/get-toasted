class_name Enemy
extends CharacterBody2D

signal killed(stats: EnemyStats)

@export var stats: EnemyStats

var target: CharacterBody2D
var hp: int


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	hp = stats.max_hp


func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp -= amount
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15).from(Color.RED)
	if hp <= 0:
		killed.emit(stats)
		queue_free()


func side(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0 else "left"
	return "down" if v.y > 0 else "up"
