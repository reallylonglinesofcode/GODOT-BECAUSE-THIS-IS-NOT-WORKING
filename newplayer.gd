extends RigidBody2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var speed = 30
#@export var hook : StaticBody2D
@export var pinjoint : PinJoint2D
var hooked = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and not hooked:
		hooked = true
		ray_cast_2d.target_position = to_local(get_global_mouse_position())
		ray_cast_2d.force_raycast_update()
		
		if ray_cast_2d.is_colliding():
			var collider = ray_cast_2d.get_collider()
			if collider.is_in_group("Hookable"):
				print("hooked")
				pinjoint.global_position = ray_cast_2d.get_collision_point()
				pinjoint.node_b = get_path_to(collider)
				
	elif Input.is_action_just_pressed("shoot") and hooked:
		hooked = false
		pinjoint.node_b = NodePath("")
	print(get_colliding_bodies())
	if Input.is_action_pressed("Right"):
		apply_central_impulse(Vector2.RIGHT)
	if Input.is_action_pressed("Left"):
		apply_central_impulse(Vector2.LEFT)
	if Input.is_action_pressed("Jump") and get_contact_count() > 0:
		apply_central_impulse(Vector2.UP * 50)
