extends RigidBody2D

# Variables for the grappling hook
@export var max_distance : float = 500.0
@export var throw_speed : float = 1200.0

var is_grappling : bool = false
var grapple_point : Vector2
var pin_joint : PinJoint2D

# References to nodes
@onready var raycast : RayCast2D = $RayCast2D
@onready var line2d : Line2D = $Line2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and not is_grappling:
		start_grapple()

	if is_grappling:
		line2d.points = [global_position, grapple_point]
	else:
		line2d.points = []

	if Input.is_action_just_released("shoot"):
		stop_grapple()

func start_grapple() -> void:
	# Set the direction of the raycast to the mouse position
	raycast.target_position = (get_global_mouse_position() - global_position).normalized() * max_distance
	raycast.enabled = true
	raycast.force_raycast_update()

	if raycast.is_colliding():
		grapple_point = raycast.get_collision_point()
		create_grapple_joint()
		is_grappling = true

func create_grapple_joint() -> void:
	pin_joint = PinJoint2D.new()
	pin_joint.position = grapple_point
	pin_joint.node_a = get_path()
	
	get_parent().add_child(pin_joint)

func stop_grapple() -> void:
	if is_grappling:
		is_grappling = false
		if pin_joint:
			pin_joint.queue_free()
			pin_joint = null

func _physics_process(delta: float) -> void:
	if is_grappling:
		var direction = (grapple_point - global_position).normalized()
		apply_central_impulse(direction * throw_speed * delta)
