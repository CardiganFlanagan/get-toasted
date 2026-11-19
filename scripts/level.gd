extends Node2D

@export var levels: Array[LevelData]
@export var music: AudioStream

@onready var toast: CharacterBody2D = $toast
@onready var jam_jar: JamJar = $all/JamJar
@onready var time_label: Label = $all/TimeLabel
@onready var end_screen: CanvasLayer = $EndScreen
@onready var run_timer: Timer = $RunTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_points: Array[Node] = $SpawnPoints.get_children()

var level: LevelData
var wave_index := 0
var kills := {}


func _ready() -> void:
	level = levels[Game.level_index]
	Music.play(music)
	jam_jar.set_value(toast.hp, toast.max_hp)
	run_timer.start(level.time_limit)
	start_next_wave()


func _process(_delta: float) -> void:
	time_label.text = str(ceili(run_timer.time_left))
	jam_jar.set_running(toast.velocity.length() > 10.0)


func start_next_wave() -> void:
	if wave_index < level.waves.size():
		spawn_timer.start(level.waves[wave_index].delay)


func _on_spawn_timer_timeout() -> void:
	var wave := level.waves[wave_index]
	for i in wave.count:
		var enemy: Enemy = wave.enemy_scene.instantiate()
		enemy.position = spawn_points[i % spawn_points.size()].position
		enemy.killed.connect(_on_enemy_killed)
		add_child(enemy)
	wave_index += 1
	start_next_wave()


func _on_enemy_killed(stats: EnemyStats) -> void:
	kills[stats] = kills.get(stats, 0) + 1


func score() -> int:
	var total := 0
	for stats in kills:
		total += kills[stats] * stats.price
	return total


func survived_seconds() -> int:
	return int(level.time_limit - run_timer.time_left)


func _on_run_timer_timeout() -> void:
	end_run(true)


func _on_toast_died() -> void:
	end_run(false)


func end_run(won: bool) -> void:
	var seconds := survived_seconds()
	var total := score()
	var new_record := Game.finish_run(seconds, won, total)
	get_tree().paused = true
	end_screen.show_result(won, level.title, seconds, kills, total, new_record)
