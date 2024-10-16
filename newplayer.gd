extends RigidBody2D

# Variables
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@export var death_y_level = 1000.0  # Set the y-level threshold for death
@export var height_limit = -10000.0  # Set the height limit for the player
var hooked = false
@onready var line_2d = $Pinjoint1/Line2d
var collision_point: Vector2 = Vector2.ZERO

# Boost variables
@export var boost_force = 200.0
@export var boost_duration = 0.5
var boost_timer = 0.0

# Hook distance
@export var max_hook_distance = 1000.0

# Input and speed tracking
var input_history: Array = []  # Stores player's inputs as strings
var speed_history: Array = []  # Stores player's speed every 10 seconds
var speed_timer = 0.0  # Timer for tracking speed every 10 seconds

func _process(delta: float) -> void:
	update_ray_cast_target()
	handle_ground_movement()
	clear_hook()
	print(global_position.y)
	testing()
	check_death_condition()  # Check if the player should die
	check_height_limit()  # Check if the player exceeds the height limit
	
	if Input.is_action_just_pressed("shoot") and not hooked:
		store_input("Shoot Pressed")
		attempt_hook()
	elif Input.is_action_just_released("shoot") and hooked:
		store_input("Shoot Released")
		release_hook()

	if hooked:
		draw_hook_line()
		handle_boost_input(delta)
	else:
		if hook:
			hook.global_position = get_global_mouse_position()

	if Input.is_action_pressed("Jump") and get_contact_count() > 0:
		store_input("Jump Pressed")
		apply_central_impulse(Vector2.UP * 50)
		# There is a slight unintentional glitch with the code, if the player is touching a wall, they can infinitely jump

	# Update the speed display on the screen
	calculate_and_display_speed(delta)

func update_ray_cast_target() -> void:
	ray_cast_2d.target_position = to_local(get_global_mouse_position())
	# This makes it so the ray stretches between the mouse and the player, detecting any collisions

func check_death_condition() -> void:
	if global_position.y > death_y_level:
		die()

func check_height_limit() -> void:
	if global_position.y < -height_limit:
		die()

func die() -> void:
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
		store_input("Boost Right")
		apply_boost(Vector2.RIGHT, delta)
	elif Input.is_action_pressed("Left"):
		store_input("Boost Left")
		apply_boost(Vector2.LEFT, delta)

func apply_boost(direction: Vector2, delta: float) -> void:
	if boost_timer <= boost_duration:
		apply_central_impulse(direction * boost_force * delta)
		boost_timer += delta
	else:
		boost_timer = 0.0

func handle_ground_movement() -> void:
	if Input.is_action_pressed("Right"):
		store_input("Move Right")
		apply_central_impulse(Vector2.RIGHT)
	if Input.is_action_pressed("Left"):
		store_input("Move Left")
		apply_central_impulse(Vector2.LEFT)

func draw_hook_line() -> void:
	line_2d.clear_points()
	line_2d.add_point(line_2d.to_local(global_position))
	line_2d.add_point(line_2d.to_local(collision_point))
	line_2d.visible = true

func clear_hook() -> void:
	line_2d.clear_points()
	line_2d.visible = false

func calculate_and_display_speed(delta: float) -> void:
	var current_speed = linear_velocity.length() / 3.6  #convert to km/h if needed
	current_speed = round(current_speed * 100) / 100  #round to two decimal places
	track_speed(current_speed, delta)

func track_speed(current_speed: float, delta: float) -> void:
	speed_timer += delta
	if speed_timer >= 10.0:  #every 10 seconds
		speed_history.append(current_speed)
		speed_timer = 0.0
		print("Speed tracked: ", current_speed)

func store_input(action: String) -> void:
	input_history.append(action)
	print("Action stored: ", action)

func testing() -> void:
	if global_position.y < death_y_level or global_position.y > height_limit:
		print("Player has died")
