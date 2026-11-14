extends Node
# Автозагрузка Game (Project Settings → Globals → Autoload).
# Хранит выбранный уровень, прогресс игрока (save.json) и настройки (settings.cfg).

const SAVE_PATH := "user://save.json"
const TMP_PATH := "user://save.tmp"
const SETTINGS_PATH := "user://settings.cfg"
const SAVE_VERSION := 1

var level_index := 0  # какая смена выбрана в меню (0 = Завтрак)
var data := {}        # прогресс: сколько смен открыто, лучшее время и лучший счёт
var volume := 1.0     # громкость 0..1


func _ready() -> void:
	data = load_progress()
	load_settings()


# ---------- Прогресс: save.json ----------

func default_data() -> Dictionary:
	return {"version": SAVE_VERSION, "unlocked": 1, "best_time": 0, "best_score": 0}


func load_progress() -> Dictionary:
	# первый запуск или после сброса: файла нет
	if not FileAccess.file_exists(SAVE_PATH):
		return default_data()

	# битый или пустой файл: parse_string вернёт null
	var loaded = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not (loaded is Dictionary):
		push_warning("save.json повреждён, начинаю с нуля")
		return default_data()

	var result := default_data()
	result.merge(loaded, true)  # чего нет в файле, берём по умолчанию
	# JSON отдаёт все числа как float (1 → 1.0), возвращаем int
	result.unlocked = int(result.unlocked)
	result.best_time = int(result.best_time)
	result.best_score = int(result.best_score)
	return result


func save_progress() -> void:
	# 1. пишем полную копию во временный файл
	var file := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Не получилось записать сохранение")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	# 2. подменяем им старый файл: если батарея сядет на шаге 1, save.json останется целым
	DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)


# Вызывает уровень, когда забег закончился (победа или смерть). Возвращает true, если это новый рекорд.
func finish_run(seconds: int, won: bool, score: int) -> bool:
	var new_record: bool = score > data.best_score
	data.best_score = maxi(data.best_score, score)
	data.best_time = maxi(data.best_time, seconds)
	if won:
		data.unlocked = maxi(data.unlocked, level_index + 2)  # открываем следующую смену
	save_progress()
	return new_record


func reset_progress() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	DirAccess.remove_absolute(SETTINGS_PATH)
	# память тоже чистим, иначе следующее сохранение запишет старое обратно
	data = default_data()
	level_index = 0
	set_volume(1.0)


# Телефон свернул игру (кнопка «Домой», звонок). Это может быть последний код, который успеет выполниться.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress()


# ---------- Настройки: settings.cfg (аналог PlayerPrefs) ----------

func load_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)  # файла нет → get_value вернёт значение по умолчанию
	set_volume(cfg.get_value("audio", "volume", 1.0))


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "volume", volume)
	cfg.save(SETTINGS_PATH)


func set_volume(value: float) -> void:
	volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))  # 0 = шина Master
