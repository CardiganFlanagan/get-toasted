extends Control

@export var plate: Plate
@export var weapon: Weapon
@export var recipes: Array[RecipeData]
@export var burnt: RecipeData

var board: Array[IngredientData] = []

@onready var plate_slots: Array[Node] = $Panel/Plate/Slots.get_children()
@onready var board_slots: Array[Node] = $Panel/Board/Slots.get_children()
@onready var cook_button: TextureButton = $Panel/Cook
@onready var result_label: Label = $Result
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func open() -> void:
	refresh()
	show()


func close() -> void:
	for item in board:
		plate.add(item)
	board.clear()
	hide()


func refresh() -> void:
	show_items(plate_slots, plate.items)
	show_items(board_slots, board)
	cook_button.disabled = board.is_empty()


func show_items(slots: Array[Node], items: Array[IngredientData]) -> void:
	for i in slots.size():
		slots[i].texture_normal = items[i].icon if i < items.size() else null


func _on_plate_slot_pressed(i: int) -> void:
	if i < plate.items.size() and board.size() < board_slots.size():
		board.append(plate.items[i])
		plate.remove(i)


func _on_board_slot_pressed(i: int) -> void:
	if i < board.size():
		plate.add(board.pop_at(i))


func _on_cook_pressed() -> void:
	var recipe := find_recipe()
	board.clear()
	weapon.equip(recipe)
	if recipe == burnt:
		$BurntSound.play()
	else:
		$CookSound.play()
	result_label.text = recipe.title
	animation_player.play("result")
	refresh()


func find_recipe() -> RecipeData:
	for recipe in recipes:
		if same_items(recipe.ingredients, board) and (recipe.upgrade_of == null or recipe.upgrade_of == weapon.recipe):
			return recipe
	return burnt


func same_items(a: Array[IngredientData], b: Array[IngredientData]) -> bool:
	var rest := b.duplicate()
	for item in a:
		if not rest.has(item):
			return false
		rest.erase(item)
	return rest.is_empty()
