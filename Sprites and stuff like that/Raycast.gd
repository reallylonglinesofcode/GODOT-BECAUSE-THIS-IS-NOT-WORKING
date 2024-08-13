extends Node2D

func _process(_delta):
	$RayCast01.target_position = to_local(get_global_mouse_position()).normalized() * 500
	
	
	
	


