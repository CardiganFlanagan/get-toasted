extends Node2D

@onready var hp_bar: Control = $all/HP_Bar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func set_health(hp: int, max_hp: int) -> void:
	hp_bar.set_health(hp, max_hp)
