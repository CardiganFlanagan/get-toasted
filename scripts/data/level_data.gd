class_name LevelData
extends Resource

@export var title: String
@export var time_limit: float
@export var spawn_every_start := 3.0
@export var spawn_every_end := 1.0
@export var max_enemies := 40
@export var spawns: Array[SpawnRule]
