class_name Wave
extends Resource
# Одна волна: кого, сколько и через сколько секунд после предыдущей волны.

@export var enemy_scene: PackedScene
@export var count: int
@export var delay: float  # больше нуля, иначе Timer не запустится
