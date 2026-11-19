class_name Weapon
extends Node2D

@export var stats: WeaponStats

var recipe: RecipeData

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = stats.cooldown


func equip(new_recipe: RecipeData) -> void:
	recipe = new_recipe
	stats = recipe.weapon
	timer.wait_time = stats.cooldown


func _on_timer_timeout() -> void:
	var enemy := find_nearest_enemy()
	if enemy == null:
		return
	var aim := global_position.direction_to(enemy.global_position)
	for i in stats.count:
		shoot(aim.rotated(deg_to_rad(stats.spread * (i - (stats.count - 1) / 2.0))))
	$ShotSound.play()


func shoot(direction: Vector2) -> void:
	var bullet: Bullet = stats.bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = direction
	bullet.rotation = direction.angle()
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
