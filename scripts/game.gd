extends Node

const SAVE_PATH := "user://save.json"
const TMP_PATH := "user://save.tmp"
const SAVE_VERSION := 1
const BUSES := {"music": &"Music", "sounds": &"SFX"}

var level_index := 0
var data := {}


func _ready() -> void:
	data = load_progress()
	apply_volume()


func default_data() -> Dictionary:
	return {"version": SAVE_VERSION, "unlocked": 1, "best_time": 0, "best_score": 0, "music": 3, "sounds": 3}


func load_progress() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_data()

	var loaded = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not (loaded is Dictionary):
		push_warning("save.json повреждён, начинаю с нуля")
		return default_data()

	var result := default_data()
	for key in result:
		if loaded.get(key) is float:  # JSON отдаёт все числа как float
			result[key] = int(loaded[key])
	return result


func save_progress() -> void:
	var file := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Не получилось записать сохранение")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)  # старый файл цел, даже если запись оборвалась


func finish_run(seconds: int, won: bool, score: int) -> bool:
	var new_record: bool = score > data.best_score
	data.best_score = maxi(data.best_score, score)
	data.best_time = maxi(data.best_time, seconds)
	if won:
		data.unlocked = maxi(data.unlocked, level_index + 2)
	save_progress()
	return new_record


func set_volume(setting: String, level: int) -> void:
	data[setting] = level
	apply_volume()
	save_progress()


func apply_volume() -> void:
	for setting in BUSES:
		var bus := AudioServer.get_bus_index(BUSES[setting])
		AudioServer.set_bus_mute(bus, data[setting] == 0)
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxi(data[setting], 1) / 3.0))


func reset_progress() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	data = default_data()
	level_index = 0
	apply_volume()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress()
