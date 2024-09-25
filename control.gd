extends Control
#calling my scences and buttons
@onready var start_button = $start_button
@onready var quit_button = $"Quit button"
@onready var mainbutton = $start_button
@export var start_level = preload("res://Sprites and stuff like that/world.tscn")
@export var main_level = preload("res://Sprites and stuff like that/main level.tscn")
#basic menu system
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Sprites and stuff like that/world.tscn")

func _on_quit_button_pressed():
	get_tree().quit()


func _on_main_button_pressed():
	get_tree().change_scene_to_file("res://Sprites and stuff like that/main level.tscn")
