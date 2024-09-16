extends RigidBody2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var speed = 200
@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D 
var hooked = false
@onready var line_2d = $Pinjoint1/Line2d
var collision_point: Vector2 = Vector2.ZERO

@export var boost_force = 200.0
@export var boost_duration = 0.5
var boost_timer = 10

@export var max_hook_distance = 1000.0
@export var gravity_direction: Vector2 = Vector2(0, 1) # Assuming downwards gravity

func _process(delta: float) -> void:
	update_ray_cast_target()

	groundmove()
	clearhook()
	
	if Input.is_action_just_pressed("shoot") and not hooked:
		var distance_to_target = global_position.distance_to(get_global_mouse_position())
		
		if distance_to_target <= max_hook_distance:
			ray_cast_2d.force_raycast_update()

			if ray_cast_2d.is_colliding():
				var collider = ray_cast_2d.get_collider()
				if collider and collider.is_in_group("Hookable"):
					collision_point = ray_cast_2d.get_collision_point()

					if hook and pinjoint:
						hook.global_position = collision_point
						pinjoint.global_position = collision_point
						pinjoint.node_b = hook.get_path()
						hooked = true
					else:
						print("Hook or PinJoint not assigned.")
	
	elif Input.is_action_just_released("shoot") and hooked:
		hooked = false
		if pinjoint:
			pinjoint.node_b = NodePath("")
		collision_point = Vector2.ZERO
		boost_timer = 0.0

	if hooked:
		draw_hook_line()
		if Input.is_action_pressed("Right"):
			apply_boost(Vector2.RIGHT, delta)
		elif Input.is_action_pressed("Left"):
			apply_boost(Vector2.LEFT, delta)
	else:
		if hook:
			hook.global_position = get_global_mouse_position()

	# Jump only if the collision is from the gravitational direction
	if Input.is_action_pressed("Jump") and get_contact_count() > 0:
		apply_central_impulse(Vector2.UP * 50)

func update_ray_cast_target() -> void:
	var mouse_position = get_global_mouse_position()
	ray_cast_2d.target_position = to_local(mouse_position)

func apply_boost(direction: Vector2, delta: float) -> void:
	if boost_timer <= boost_duration:
		apply_central_impulse(direction * boost_force * delta)
		boost_timer += delta
	else:
		boost_timer = 0.0  

func groundmove():
	if Input.is_action_pressed("Right"):
		apply_central_impulse(Vector2.RIGHT)
	if Input.is_action_pressed("Left"):
		apply_central_impulse(Vector2.LEFT)

func draw_hook_line() -> void:
	var player_local_position = line_2d.to_local(global_position)
	var hook_local_position = line_2d.to_local(collision_point)
	
	line_2d.add_point(player_local_position)  
	line_2d.add_point(hook_local_position)    
	line_2d.visible = true

func clearhook():
	line_2d.clear_points()
	line_2d.visible = false 
