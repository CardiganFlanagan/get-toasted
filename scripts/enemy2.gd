extends Enemy
# Преследователь: идёт к тосту и кусает, пока касается. stats, target и hp — в enemy.gd

@export var navigation_agent_2d: NavigationAgent2D

@onready var timer: Timer = $hitbox/Timer

func _ready() -> void:
	super()  # сначала общий _ready из enemy.gd
	timer.wait_time = stats.cooldown_time


func _physics_process(delta: float) -> void:
	navigation_agent_2d.target_position = target.global_position
	velocity = global_position.direction_to(navigation_agent_2d.get_next_path_position()) * stats.speed
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(stats.damage)
		timer.start()


func _on_timer_timeout() -> void:
	target.take_damage(stats.damage)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timer.stop()
