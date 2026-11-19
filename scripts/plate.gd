class_name Plate
extends Node

signal changed(crumbs: int, items: Array)

@export var size := 6

var crumbs := 0
var items: Array[IngredientData] = []


func add_crumbs(amount: int) -> void:
	crumbs += amount
	$PickupSound.play()
	changed.emit(crumbs, items)


func can_buy(item: IngredientData) -> bool:
	return crumbs >= item.price and items.size() < size


func buy(item: IngredientData) -> void:
	crumbs -= item.price
	add(item)


func add(item: IngredientData) -> void:
	items.append(item)
	changed.emit(crumbs, items)


func remove(i: int) -> void:
	items.remove_at(i)
	changed.emit(crumbs, items)
