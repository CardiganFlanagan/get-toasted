extends CharacterBody2D
@onready var timer: Timer = $hitbox/Timer
@export var target: CharacterBody2D
@export var navigation_agent_2d: NavigationAgent2D



signal hit
const SPEED = 100

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	navigation_agent_2d.target_position = target.global_position
	velocity = global_position.direction_to(navigation_agent_2d.get_next_path_position()) * SPEED
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(4)
		timer.start()
		


	
	


func _on_timer_timeout() -> void:
	target.take_damage(4)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timer.stop()
