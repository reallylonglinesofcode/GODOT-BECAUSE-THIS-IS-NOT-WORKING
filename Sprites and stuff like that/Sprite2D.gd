extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	ghosting()

func set_property(tx_pos, tx_scale ):
	position = tx_pos
	scale = tx_scale

func ghosting():
	var tweenfade = get_tree().create_tween()
	
	tweenfade.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.75)
	await tweenfade.finished
	queue_free()
