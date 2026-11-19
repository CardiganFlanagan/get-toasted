extends Node2D


func _ready() -> void:
	scale = Vector2.ONE / get_parent().scale
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED


func thaw() -> void:
	get_parent().process_mode = Node.PROCESS_MODE_INHERIT
