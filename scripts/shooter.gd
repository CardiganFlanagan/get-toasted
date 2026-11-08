extends CharacterBody2D


enum State { CHASE, RETREAT, AIM, COOLDOWN }

@export var target: CharacterBody2D
@export var bullet_scene: PackedScene
@export var speed := 100.0
@export var shoot_range := 250.0
@export var retreat_range := 150.0
@export var retreat_time := 1.0  
@export var aim_time := 0.7       
@export var cooldown_time := 1.5
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var state := State.CHASE
var timer := 0.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	print("bee layer=", collision_layer, " mask=", collision_mask,
		" | toast layer=", target.collision_layer, " mask=", target.collision_mask,
		" | bee shapes=", get_shape_owners().size())
	target = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	timer -= delta
	var dist := global_position.distance_to(target.global_position)
	var sees_player := can_see_player()

	match state:
		State.CHASE:
			navigation_agent_2d.target_position = target.global_position
			velocity = global_position.direction_to(navigation_agent_2d.get_next_path_position()) * speed
			if sees_player and dist < retreat_range:
				change_state(State.RETREAT, retreat_time)
			elif sees_player and dist <= shoot_range:
				change_state(State.AIM, aim_time)

		State.RETREAT:
			velocity = target.global_position.direction_to(global_position) * speed
			if dist >= retreat_range or timer <= 0:
				change_state(State.AIM, aim_time)

		State.AIM:
			velocity = Vector2.ZERO
			if not sees_player or dist > shoot_range:
				change_state(State.CHASE, 0) 
			elif timer <= 0:
				shoot()
				change_state(State.COOLDOWN, cooldown_time)

		State.COOLDOWN:
			velocity = Vector2.ZERO
			if not animated_sprite_2d.is_playing(): 
				animated_sprite_2d.play("tired")
			if timer <= 0:
				change_state(State.CHASE, 0)

	move_and_slide()
	animated_sprite_2d.flip_h = target.global_position.x < global_position.x
	queue_redraw()

func change_state(new_state: State, time: float) -> void:
	state = new_state
	timer = time
	match state:
		State.CHASE, State.RETREAT:
			animated_sprite_2d.play("fly")
		State.AIM:
			animated_sprite_2d.play("aim")
		State.COOLDOWN:
			animated_sprite_2d.play("shoot")


func can_see_player() -> bool:
	ray_cast_2d.target_position = ray_cast_2d.to_local(target.global_position)
	ray_cast_2d.force_raycast_update()  
	return ray_cast_2d.get_collider() == target


func shoot() -> void:
	var bullet: Bullet = bullet_scene.instantiate()  
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(target.global_position)
	bullet.rotation = bullet.direction.angle()


func _draw() -> void:
	if state == State.AIM:
		var to_target := to_local(target.global_position)
		var dots := int(to_target.length() / 24) 
		for i in range(1, dots):
			draw_rect(Rect2(to_target * i / dots - Vector2(2, 2), Vector2(4, 4)), Color("d64844"))
