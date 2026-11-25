extends Node2D

@export var levels: Array[LevelData]
@export var music: AudioStream
@export var marker_scene: PackedScene
@export var arena := Rect2(80, 160, 1376, 760)

@onready var toast: CharacterBody2D = $toast
@onready var jam_jar: JamJar = $all/JamJar
@onready var time_label: Label = $all/TimeLabel
@onready var end_screen: CanvasLayer = $EndScreen
@onready var run_timer: Timer = $RunTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_points: Array[Node] = $SpawnPoints.get_children()

var level: LevelData
var kills := {}


func _ready() -> void:
	level = levels[Game.level_index]
	Music.play(music)
	jam_jar.set_value(toast.hp, toast.max_hp)
	run_timer.start(level.time_limit)
	spawn_timer.start(1.0)


func _process(_delta: float) -> void:
	time_label.text = str(ceili(run_timer.time_left))
	jam_jar.set_running(toast.velocity.length() > 10.0)


func _on_spawn_timer_timeout() -> void:
	var progress := float(survived_seconds()) / level.time_limit
	spawn_timer.start(lerpf(level.spawn_every_start, level.spawn_every_end, progress))
	if get_tree().get_nodes_in_group("enemies").size() >= level.max_enemies:
		return
	var rule := pick_rule()
	var center := random_point()
	for i in randi_range(rule.group_min, rule.group_max):
		var marker: SpawnMarker = marker_scene.instantiate()
		marker.enemy_scene = rule.enemy_scene
		marker.position = on_floor(center + Vector2(randf_range(-32, 32), randf_range(-32, 32)))
		marker.spawned.connect(add_enemy)
		add_child(marker)


func pick_rule() -> SpawnRule:
	var open: Array[SpawnRule] = []
	var total := 0.0
	for rule in level.spawns:
		if rule.from_second <= survived_seconds():
			open.append(rule)
			total += rule.weight
	var roll := randf() * total
	for rule in open:
		roll -= rule.weight
		if roll <= 0:
			return rule
	return open.back()


func random_point() -> Vector2:
	for i in 10:
		var point := on_floor(Vector2(randf_range(arena.position.x, arena.end.x), randf_range(arena.position.y, arena.end.y)))
		if point != Vector2.ZERO and point.distance_to(toast.position) > 180:
			return point
	return spawn_points.pick_random().position


func on_floor(point: Vector2) -> Vector2:
	return NavigationServer2D.map_get_closest_point(get_world_2d().navigation_map, point)


func add_enemy(enemy: Enemy) -> void:
	enemy.killed.connect(_on_enemy_killed)
	add_child(enemy)


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
