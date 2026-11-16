extends Enemy

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $hitbox/Timer


func _ready() -> void:
	super()
	timer.wait_time = stats.cooldown_time


func _physics_process(_delta: float) -> void:
	var biting := sprite.animation.begins_with("bite") and sprite.is_playing()
	nav.target_position = target.global_position
	velocity = Vector2.ZERO if biting else global_position.direction_to(nav.get_next_path_position()) * stats.speed
	move_and_slide()
	if not biting and velocity.length() > 1:
		sprite.play("move_" + side(velocity))


func bite() -> void:
	target.take_damage(stats.damage)
	sprite.play("bite_" + side(target.global_position - global_position))


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bite()
		timer.start()


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timer.stop()
