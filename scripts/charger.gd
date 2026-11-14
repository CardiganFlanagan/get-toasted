extends Enemy
# Жук: Погоня → Замах → Рывок → Отдых. stats, target и hp — в enemy.gd


enum State { CHASE, WINDUP, DASH, COOLDOWN }

const ANIMS := {State.CHASE: "move", State.WINDUP: "windup", State.DASH: "dash", State.COOLDOWN: "tired"}

var state := State.CHASE
var timer := 0.0
var dash_dir := Vector2.ZERO
var facing := Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sweat: Sprite2D = $Sweat
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var ray: RayCast2D = $RayCast2D


func _physics_process(delta: float) -> void:
	timer -= delta
	var to_player := target.global_position - global_position

	match state:
		State.CHASE:
			nav.target_position = target.global_position
			velocity = global_position.direction_to(nav.get_next_path_position()) * stats.speed
			if velocity.length() > 1:
				facing = velocity.normalized()
			if to_player.length() < stats.vision_range and has_clear_line(to_player):
				dash_dir = to_player.normalized()  
				facing = dash_dir
				change_state(State.WINDUP, stats.windup_time)

		State.WINDUP:
			velocity = Vector2.ZERO
			sprite.modulate = Color.RED if int(timer * 10) % 2 == 0 else Color.WHITE
			if timer <= 0:
				change_state(State.DASH, stats.dash_time)

		State.DASH:
			velocity = dash_dir * stats.dash_speed
			if timer <= 0:
				change_state(State.COOLDOWN, stats.cooldown_time)

		State.COOLDOWN:
			velocity = Vector2.ZERO
			sprite.modulate = Color(0.6, 0.6, 0.6)
			if timer <= 0:
				change_state(State.CHASE, 0)

	move_and_slide()

	if state == State.DASH and get_last_slide_collision():
		if get_last_slide_collision().get_collider() == target:
			target.take_damage(stats.damage)
		change_state(State.COOLDOWN, stats.cooldown_time)

	sweat.visible = state == State.COOLDOWN
	sprite.play(ANIMS[state] + "_" + direction_name())


func change_state(new_state: State, time: float) -> void:
	state = new_state
	timer = time
	sprite.modulate = Color.WHITE


func has_clear_line(to_player: Vector2) -> bool:
	ray.target_position = to_player
	ray.force_raycast_update()
	return ray.get_collider() == target


func direction_name() -> String:
	if abs(facing.x) > abs(facing.y):
		return "right" if facing.x > 0 else "left"
	return "down" if facing.y > 0 else "up"
