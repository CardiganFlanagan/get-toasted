extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var toast: CharacterBody2D = $"."
var speed = 200 
signal hp_changed(hp: int, max_hp: int)
var invincible: bool = false




@export var max_hp := 25
var hp := max_hp
@onready var hp_jar: JamJar = $"../all/JamJar"

func _physics_process(delta):
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction * speed
	hp_jar.set_running(velocity.length() > 10.0)

	move_and_slide()
	
	if direction != Vector2.ZERO:
		sprite_2d.play("walk")
		if direction.x != 0:
			sprite_2d.flip_h = direction.x < 0
	else:
		sprite_2d.play("idle")


#func take_damage(amount: int) -> void:
	#hp = maxi(hp - amount, 0)
	#hp_changed.emit(hp, max_hp)
	
#func take_damage(amount: int) -> void:
	#hp = maxi(hp - amount, 0)
	#hp_jar.set_value(hp, max_hp)


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	#hp = maxi(hp + amount, 0.0)
	hp_jar.set_value(hp, max_hp)
	
func take_damage(amount:int, invincible_time = 4) -> void:
	if invincible: 
		return
		
	hp = maxi(hp - amount, 0)
	hp_jar.set_value(hp, max_hp)
	
	if hp<=0:
		get_tree().reload_current_scene()
	
	if invincible_time > 0 :
		invincible = true
		var invincible_tween = create_tween().set_trans(Tween.TRANS_SINE)
		invincible_tween.tween_property($Sprite2D, "modulate:a",0.25,invincible_time/4)
		invincible_tween.chain().tween_property($Sprite2D, "modulate:a",1,invincible_time/4)
		invincible_tween.chain().chain().tween_property($Sprite2D, "modulate:a",0.25,invincible_time/4)
		invincible_tween.chain().chain().tween_property($Sprite2D, "modulate:a",1,invincible_time/4).finished.connect(func(): invincible = false)	
	
	
