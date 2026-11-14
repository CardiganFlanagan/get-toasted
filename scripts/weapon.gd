extends Node2D
# Оружие тоста: само стреляет крошкой в ближайшего врага в радиусе.
# Как часто стрелять — Timer в weapon.tscn, его время берём из stats.

@export var stats: WeaponStats         # data/weapons/crumbs.tres
@export var bullet_scene: PackedScene  # scenes/crumb.tscn

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = stats.cooldown


func _on_timer_timeout() -> void:
	var enemy := find_nearest_enemy()
	if enemy == null:
		return
	var bullet: Bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(enemy.global_position)
	bullet.rotation = bullet.direction.angle()
	bullet.speed = stats.bullet_speed
	bullet.damage = stats.damage


func find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := stats.attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	return nearest
