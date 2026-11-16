extends CharacterBody2D

signal hp_changed(hp: int, max_hp: int)
signal died

@export var stats: PlayerStats

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var max_hp: int
var hp: int
var invincible := false


func _ready() -> void:
	max_hp = stats.max_hp
	hp = max_hp


func _physics_process(delta):
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction * stats.speed
	move_and_slide()

	if direction != Vector2.ZERO:
		sprite_2d.play("walk")
		if direction.x != 0:
			sprite_2d.flip_h = direction.x < 0
	else:
		sprite_2d.play("idle")


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	hp_changed.emit(hp, max_hp)


func take_damage(amount: int) -> void:
	if invincible or hp <= 0:
		return

	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		died.emit()
		return

	invincible = true
	var blink := create_tween().set_loops(2)
	blink.tween_property(sprite_2d, "modulate:a", 0.25, stats.invincible_time / 4)
	blink.tween_property(sprite_2d, "modulate:a", 1.0, stats.invincible_time / 4)
	blink.finished.connect(func(): invincible = false)
