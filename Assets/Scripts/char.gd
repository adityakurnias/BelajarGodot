class_name Player
extends CharacterBody3D

## Movement
@export var speed: float
@export var WALK_SPEED: float = 4.5
@export var SPRINT_SPEED: float = 8.5
@export var JUMP_VELOCITY: float = 5
@export var SENSITIVITY: float = 0.003
@export var CROUCH_MOVESPEED: float = 1.5
@export var TOUCH_CEILINGS_MOV_SPEED: float = 1.8
@export var CROUCH_SPEED: int = 20
@export var ACCELERATION: float = 0.08
@export var DECCELERATION: float = 0.25

## Character
# FOV
@export var DEFAULT_FOV: float = 75.0
@export var FOV_MULTIPLIER: float = 2
# Height
@export var DEFAULT_HEIGHT: float = 2.0
@export var CROUCH_HEIGHT: float = 0.8
@export var autocrouch: Vector3 = Vector3()
# Head Bob Var
@export var BOB_FREQ: float = 2.0
@export var BOB_AMP: float = 0.08
@export var t_bob: float = 0.0

# Body
@onready var head: Object = $Head
@onready var cam: Object = $Head/Camera3D
@onready var player: Object = $CollisionShape3D
@onready var headray: Object = $Head/UpperHeadRay

var exit: bool = false
var touch_ceiling: bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Global.player = self
	speed = WALK_SPEED
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	var can_move = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if can_move:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		cam.rotate_x(-event.relative.y * SENSITIVITY)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _input(event):
	if event.is_action_pressed("exit"):
		if !exit:
			velocity.y = 0
			exit = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			exit = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Check if head touch someting
	if headray.is_colliding():
		touch_ceiling = true
	else:
		touch_ceiling = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif touch_ceiling:
		autocrouch.y -= -2
		speed = TOUCH_CEILINGS_MOV_SPEED
	elif Input.is_action_pressed("crouch"):
		speed = CROUCH_MOVESPEED
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction : Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * speed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECCELERATION)
		velocity.z = move_toward(velocity.z, 0, DECCELERATION)
	#else:
		#velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		#velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Handle headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	cam.transform.origin = headbob(t_bob)
	
	#crouch(delta)
	fov_change(delta)
	move_and_slide()
	
	Global.debug.add_property("Move Speed", speed, 1)
	Global.debug.add_property("Is Touching Ceiling", touch_ceiling, 2)
	Global.debug.add_property("Player Height", player.shape.height, 3)
	Global.debug.add_property("Velocity Length", velocity.length(), 4)
	Global.debug.add_property("Velocity X", velocity.x, 5)
	Global.debug.add_property("Velocity Z", velocity.z, 6)
	Global.debug.add_property("Is on floor", is_on_floor(), 7)

# Headbob
func headbob(time) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos   

# Crouching
func crouch(delta : float):
	if Input.is_action_pressed("crouch"):
		player.shape.height -= CROUCH_SPEED * delta
	elif not touch_ceiling:
		player.shape.height += CROUCH_SPEED * delta
	player.shape.height = clamp(player.shape.height, CROUCH_HEIGHT, DEFAULT_HEIGHT)

func fov_change(delta : float):
	# Handle FOV change
	var velocity_clamped: float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov: float = DEFAULT_FOV + FOV_MULTIPLIER * velocity_clamped
	cam.fov = lerp(cam.fov, target_fov, delta * 8.0)
