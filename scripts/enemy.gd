class_name Enemy
extends CharacterBody2D
# Общее для всех врагов: числа из EnemyStats, цель (тост), HP и смерть.
# Преследователь, жук и пчела наследуют этот скрипт: extends Enemy.

signal killed(stats: EnemyStats)  # уровень считает убитых для чека

@export var stats: EnemyStats

var target: CharacterBody2D
var hp: int


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	hp = stats.max_hp


# Вызывает крошка тоста при попадании
func take_damage(amount: int) -> void:
	if hp <= 0:
		return  # уже умирает: две крошки в одном кадре не убивают дважды
	hp -= amount
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15).from(Color.RED)  # вспышка
	if hp <= 0:
		killed.emit(stats)
		queue_free()
