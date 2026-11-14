class_name EnemyStats
extends Resource
# Числа одного типа врага. Один .tres на тип, его делят все враги этого типа.
# Текущее состояние (позиция, таймеры, HP) живёт в самом враге, а не здесь.

@export var title: String       # как враг называется в чеке
@export var price: int          # сколько стоит в чеке за одного
@export var speed: float
@export var max_hp: int
@export var damage: int
@export var vision_range: float   # с какого расстояния замечает игрока
@export var windup_time: float    # замах перед атакой
@export var cooldown_time: float  # отдых после атаки

@export_group("Жук: рывок")
@export var dash_speed: float
@export var dash_time: float

@export_group("Пчела: стрельба")
@export var retreat_range: float  # ближе этого отлетает назад
@export var retreat_time: float
@export var bullet_speed: float
