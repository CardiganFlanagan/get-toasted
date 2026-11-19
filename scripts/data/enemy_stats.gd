class_name EnemyStats
extends Resource

@export var title: String
@export var price: int
@export var crumbs: int
@export var speed: float
@export var max_hp: int
@export var damage: int
@export var vision_range: float
@export var windup_time: float
@export var cooldown_time: float

@export_group("Жук: рывок")
@export var dash_speed: float
@export var dash_time: float

@export_group("Пчела: стрельба")
@export var retreat_range: float
@export var retreat_time: float
@export var bullet_speed: float
