extends Control

@export var plate: Plate
@export var stock: Array[IngredientData]

var offers: Array[IngredientData] = []

@onready var cards: Array[Node] = $Panel/Cards.get_children()
@onready var restock_timer: Timer = $Restock
@onready var restock_label: Label = $Panel/RestockLabel


func _ready() -> void:
	restock()


func _process(_delta: float) -> void:
	restock_label.text = "новый товар: %d" % ceili(restock_timer.time_left)


func open() -> void:
	refresh()
	show()


func restock() -> void:
	offers.clear()
	for card in cards:
		offers.append(stock.pick_random())
	refresh()


func refresh() -> void:
	for i in cards.size():
		var card: TextureButton = cards[i]
		var item := offers[i]
		card.get_node("Sold").visible = item == null
		card.get_node("Info").visible = item != null
		card.disabled = item == null or not plate.can_buy(item)
		if item:
			card.get_node("Info").modulate.a = 0.5 if card.disabled else 1.0
			card.get_node("Info/Icon").texture = item.icon
			card.get_node("Info/Name").text = item.title
			card.get_node("Info/Price").text = str(item.price)


func _on_card_pressed(i: int) -> void:
	var item := offers[i]
	offers[i] = null
	plate.buy(item)
