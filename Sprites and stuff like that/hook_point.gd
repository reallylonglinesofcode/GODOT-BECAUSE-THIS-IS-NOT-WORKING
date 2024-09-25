extends StaticBody2D

#this is for my animation
@export var click_animation_name: String = "click"
@export var idle_animation_name: String = "idle"

@onready var animation_player = $AnimatedSprite2D
var mouse_is_pressed: bool = false

func _ready():
	animation_player.play(idle_animation_name)
#if the mouse button is clicked it plays and if is not clicked, it does not play, you can also see if attempt is a  
#fail because you can see the hook animation play but not the rope animation
func _input(event):
	# Check for mouse button pressed event
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_is_pressed = event.pressed
			if mouse_is_pressed:
				play_click_animation()
			else:
				play_idle_animation()

func play_click_animation():
	# Play click animation
	animation_player.play(click_animation_name)

func play_idle_animation():
	# Play idle animation
	animation_player.play(idle_animation_name)
