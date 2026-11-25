class_name Enemy
extends CharacterBody2D

signal killed(stats: EnemyStats)

@export var stats: EnemyStats
@export var drop_scene: PackedScene
@export var death_scene: PackedScene
@export var hit_effect: PackedScene

var target: CharacterBody2D
var hp: int


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	hp = stats.max_hp


func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp -= amount
	Juice.flash($AnimatedSprite2D)
	spawn(hit_effect)
	if hp <= 0:
		killed.emit(stats)
		var burst: PixelBurst = spawn(death_scene)
		burst.explode($AnimatedSprite2D)
		var drop: Pickup = spawn(drop_scene)
		if drop:
			drop.amount = stats.crumbs
		queue_free()


func spawn(scene: PackedScene) -> Node2D:
	if scene == null:
		return null
	var node: Node2D = scene.instantiate()
	node.position = position
	get_parent().add_child.call_deferred(node)
	return node


func side(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0 else "left"
	return "down" if v.y > 0 else "up"
