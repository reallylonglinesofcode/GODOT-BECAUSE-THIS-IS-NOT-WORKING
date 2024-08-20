extends CharacterBody2D

@export var SPEED = 35000
@export var JUMP_VELOCITY = -50000
@export var START_GRAVITY = 1700
@export var COYOTE_TIME = 140 # in ms
@export var JUMP_BUFFER_TIME = 100 # in ms
@export var JUMP_CUT_MULTIPLIER = 0.4
@export var AIR_HANG_MULTIPLIER = 0.93
@export var AIR_HANG_THRESHOLD = 50
@export var Y_SMOOTHING = 0.8
@export var AIR_X_SMOOTHING = 0.1
@export var MAX_FALL_SPEED = 25000
@onready var ray = $RayCast2D
var hook_pos = Vector2()
var hooked = false
var rope_length = 500
var current_rope_length
var motion = Vector2()
@onready var swingpoint = get_parent()
enum States {
	IDLE,
	RUN,JUMP,
	AIR,
	DEAD,
}

@onready var state: States = States.AIR
var prevVelocity = Vector2.ZERO
var lastFloorMsec = 0
var wasOnFloor = false
var lastJumpQueueMsec: int
var gravity = START_GRAVITY

func _ready():
	set_meta("tag", "player")
	current_rope_length = rope_length

func _physics_process(delta):
	if hooked:
		swing()
		return
	
		
	var direction = Input.get_axis("Left", "Right")
	
	if is_on_floor():
		lastFloorMsec = Time.get_ticks_msec()
	elif state != States.JUMP and state != States.AIR and state != States.DEAD:
		state = States.AIR
	
	match state:
		States.JUMP:
			velocity.y = JUMP_VELOCITY * delta
			state = States.AIR
		States.AIR:
			if is_on_floor():
				state = States.IDLE
			if Input.is_action_just_released("Jump"):
				velocity.y *= JUMP_CUT_MULTIPLIER
			run(direction, delta)
			velocity.x = lerp(prevVelocity.x, velocity.x, AIR_X_SMOOTHING)
			if Input.is_action_just_pressed("Jump"):
				if Time.get_ticks_msec() - lastFloorMsec < COYOTE_TIME:
					state = States.JUMP
				else:
					lastJumpQueueMsec = Time.get_ticks_msec()
			velocity.y += gravity * delta
			if abs(velocity.y) < AIR_HANG_THRESHOLD:
				gravity *= AIR_HANG_MULTIPLIER
			else:
				gravity = START_GRAVITY
		States.IDLE:
			if Time.get_ticks_msec() - lastJumpQueueMsec < JUMP_BUFFER_TIME or Input.is_action_just_pressed("Jump"): # jump buffer
				state = States.JUMP
			else:
				velocity.x = 0
				if direction != 0:
					state = States.RUN
		States.RUN:
			run(direction, delta)
			
			if direction == 0:
				state = States.IDLE
			elif Input.is_action_just_pressed("Jump"): 
				state = States.JUMP
		States.DEAD:
			pass
	
	velocity.y = lerp(prevVelocity.y, velocity.y, Y_SMOOTHING)
	
	velocity.y = min(velocity.y, MAX_FALL_SPEED * delta)
	
	wasOnFloor = is_on_floor()
	prevVelocity = velocity
	
	move_and_slide()
	#print(motion)
	hook()
	if Input.is_action_just_pressed("shoot"):
		if ray.is_colliding():
			hook_pos = ray.get_collision_point()
			swingpoint.global_position = hook_pos
			hooked = true
			
	#if hooked:
		#gravity = START_GRAVITY
		#swing(delta)
		#motion *= 0.96
		#motion = move_and_slide()
func swing():
	swingpoint.rotation_degrees+=1
	
func run(direction, delta):
	velocity.x = SPEED * direction * delta
#
func hook():
	ray.target_position = to_local(get_global_mouse_position()).normalized() * 500
	#if Input.is_action_just_pressed("shoot"):
		#hook_pos = get_hooked_pos()
		#if hook_pos:
			#hooked = true
			#current_rope_length = global_position.distance_to(hook_pos)

#func get_hooked_pos():
	#if ray.is_colliding:
		#
		#return ray.get_collision_point()

#func swing(delta):
	#var radius = global_position - hook_pos
	#if motion.length() < 0.01 or radius.length() < 10: 
		#return
	#var angle = acos(radius.dot(motion) / (radius.length * SPEED.length()))
	#var rad_vel = cos(angle) * motion.length()
	#SPEED += radius.normalized * -rad_vel
	#
	#if global_position.distance_to(hook_pos) > current_rope_length:
		#global_position = hook_pos + radius.normalized() * current_rope_length
	#
	#motion += (hook_pos - global_position).normalized() * 15000 * delta
