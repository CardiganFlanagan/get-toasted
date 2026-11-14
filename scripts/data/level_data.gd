class_name LevelData
extends Resource
# Одна смена (уровень опасности): сколько продержаться и какие волны врагов приходят.
# Точки появления врагов стоят в сцене уровня (узел SpawnPoints).

@export var title: String       # название смены в меню и в чеке
@export var time_limit: float  # секунд до победы
@export var waves: Array[Wave]
