extends Node2D

@onready var player = $".."
@onready var player_pos = player.position
@onready var player_global_pos = player.global_position
@onready var mouse_pos = get_mouse_global_position()
@onready var position_to_mouse = mouse_pos - player_global_pos

func _process(delta):
	look_at(position_to_mouse.rotated(-PI/2))




