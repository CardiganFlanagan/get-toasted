extends Node2D

@export var weapon_scene: PackedScene


func rebuild(items: Array) -> void:
	for child in get_children():
		child.queue_free()
	for item: IngredientData in items:
		var weapon: Weapon = weapon_scene.instantiate()
		weapon.stats = item.weapon
		add_child(weapon)
