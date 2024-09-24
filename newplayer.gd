extends RigidBody2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D 
@export var death_y_level = 0  # Set the y-level threshold for death
var hooked = false
@onready var line_2d = $Pinjoint1/Line2d
var collision_point: Vector2 = Vector2.ZERO

@export var boost_force = 200.0
@export var boost_duration = 0.5
var boost_timer = 0.0

@export var max_hook_distance = 1000.0

func _process(delta: float) -> void:
	update_ray_cast_target()
	print(position)
	handle_ground_movement()
	clear_hook()

	check_death_condition()  # Check if the player should die

	if Input.is_action_just_pressed("shoot") and not hooked:
		attempt_hook()

	elif Input.is_action_just_released("shoot") and hooked:
		release_hook()

	if hooked:
		draw_hook_line()
		handle_boost_input(delta)
	else:
		if hook:
			hook.global_position = get_global_mouse_position()

	if Input.is_action_pressed("Jump") and get_contact_count() > 0:
		apply_central_impulse(Vector2.UP * 50)

	# Update the speed display on the screen
	calculate_and_display_speed()

func update_ray_cast_target() -> void:
	ray_cast_2d.target_position = to_local(get_global_mouse_position())

func check_death_condition() -> void:
	if global_position.y > death_y_level:
		die()

func die() -> void:
	print("Player has died!")
	queue_free()  # Remove the player from the scene or handle game over logic

func attempt_hook() -> void:
	var distance_to_target = global_position.distance_to(get_global_mouse_position())
	if distance_to_target <= max_hook_distance:
		ray_cast_2d.force_raycast_update()
		if ray_cast_2d.is_colliding():
			var collider = ray_cast_2d.get_collider()
			if collider and collider.is_in_group("Hookable"):
				collision_point = ray_cast_2d.get_collision_point()
				hook.global_position = collision_point
				pinjoint.global_position = collision_point
				pinjoint.node_b = hook.get_path()
				hooked = true

func release_hook() -> void:
	hooked = false
	if pinjoint:
		pinjoint.node_b = NodePath("")
	collision_point = Vector2.ZERO
	boost_timer = 0.0

func handle_boost_input(delta: float) -> void:
	if Input.is_action_pressed("Right"):
		apply_boost(Vector2.RIGHT, delta)
	elif Input.is_action_pressed("Left"):
		apply_boost(Vector2.LEFT, delta)

func apply_boost(direction: Vector2, delta: float) -> void:
	if boost_timer <= boost_duration:
		apply_central_impulse(direction * boost_force * delta)
		boost_timer += delta
	else:
		boost_timer = 0.0  

func handle_ground_movement() -> void:
	if Input.is_action_pressed("Right"):
		apply_central_impulse(Vector2.RIGHT)
	if Input.is_action_pressed("Left"):
		apply_central_impulse(Vector2.LEFT)

func draw_hook_line() -> void:
	line_2d.clear_points()
	line_2d.add_point(line_2d.to_local(global_position))  
	line_2d.add_point(line_2d.to_local(collision_point))    
	line_2d.visible = true

func clear_hook() -> void:
	line_2d.clear_points()
	line_2d.visible = false

func calculate_and_display_speed() -> void:
	var current_speed = linear_velocity.length() / 3.6  # Convert to km/h if needed
	current_speed = round(current_speed * 100) / 100  # Rounds to two decimal places
