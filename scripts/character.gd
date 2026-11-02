extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var toast: CharacterBody2D = $"."
var speed = 200 


func _physics_process(delta):
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction * speed

	move_and_slide()
	
	if direction != Vector2.ZERO:
		sprite_2d.play("walk")
		if direction.x != 0:
			sprite_2d.flip_h = direction.x < 0
	else:
		sprite_2d.play("idle")
