class_name SpawnMarker
extends Node2D

signal spawned(enemy: Enemy)

var enemy_scene: PackedScene


func spawn() -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.position = position
	spawned.emit(enemy)
	queue_free()
