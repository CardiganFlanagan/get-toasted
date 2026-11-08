extends Node2D
@onready var toast: CharacterBody2D = $toast
@onready var hp_bar: Control = $all/HP_Bar

@onready var jam_jar: JamJar = $all/JamJar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

#func set_health(hp: int, max_hp: int) -> void:
	#hp_bar.set_health(hp, max_hp)

func set_health(hp: int, max_hp: int) -> void:
	jam_jar.set_health(hp, max_hp)
	
func _on_heal_heal() -> void:
	toast.heal(5)



#func _on_enemy_hit() -> void:
	#toast.take_damage(6)
