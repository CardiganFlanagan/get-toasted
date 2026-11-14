extends CanvasLayer
# Чек в конце смены. Вся анимация лежит в AnimationPlayer (show, again, to_menu),
# код только подставляет числа и выбирает: победа или поражение.

@export var enemy_types: Array[EnemyStats]  # строки чека сверху вниз
@export var stamp_paid: Texture2D
@export var stamp_burnt: Texture2D

@onready var rows: Array[Node] = $Board/Slot/Receipt/Rows.get_children()


func show_result(won: bool, shift: String, seconds: int, kills: Dictionary, total: int, new_record: bool) -> void:
	set_row(rows[0], "Смена", shift)
	set_row(rows[1], "Время", "%d:%02d" % [seconds / 60, seconds % 60])
	for i in enemy_types.size():
		var stats := enemy_types[i]
		var count: int = kills.get(stats, 0)
		set_row(rows[i + 2], "%s ×%d" % [stats.title, count], str(count * stats.price))
	set_row($Board/Slot/Receipt/Total, "ИТОГО", str(total))
	$Board/Slot/Receipt/Record.visible = new_record
	$Board/Slot/Receipt/Stamp.texture = stamp_paid if won else stamp_burnt
	$Board/Toast/Win.visible = won
	$Board/Toast/Burnt.visible = not won
	$Board/Caption.text = "Смена закрыта!" if won else "Тост подгорел..."
	show()
	$AnimationPlayer.play("show")
	$AnimationPlayer.advance(0)  # сразу ставит всё на стартовые места, чтобы не мелькнул готовый чек


func set_row(row: Node, title: String, value: String) -> void:
	row.get_node("Name").text = title
	row.get_node("Value").text = value


# Эти две функции вызывают анимации again и to_menu (дорожка Call Method), когда кнопка доиграла

func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")


# Esc открывает меню паузы и снимает паузу. Под чеком это не нужно: забираем нажатие себе.
func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
