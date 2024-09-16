extends Control

@onready var start_button = $start_button
@onready var quit_button = $"Quit button"
@onready var toutbutton = $"tout button"
@export var start_level = preload("res://Sprites and stuff like that/world.tscn")


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Sprites and stuff like that/world.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
