extends CharacterBody3D

# Player Speed (m/s)
@export var speed = 4.0

@export var gravity = 9.8 # m/s^2

@export var mouse_sensitivity = 0.07

@export var clamp_deg = [-45,20]

@export var prev_velocity: Vector3 = Vector3.ZERO

@onready var camera_pivot: Node3D = $tps_CameraPivot
@onready var pivot: Node3D = $Pivot


func _ready():

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 滑鼠左右移動 -> 直接旋轉玩家本體 (CharacterBody3D)
		rotate_y(-event.relative.x * mouse_sensitivity)
		# 滑鼠上下移動 -> 只旋轉攝影機樞紐 (CameraPivot)，並限制上下俯仰角度
		# need to set the rotation properties in the child node to avoid the error in clamp cal
		camera_pivot.rotate_z(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.z = clamp(camera_pivot.rotation.z, deg_to_rad(clamp_deg[0]), deg_to_rad(clamp_deg[1]))
	
	# prevent mouse lock
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("jump"):
		velocity.y = 10
			
	# lock mouse with click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):

	var input_dir = Input.get_vector("ui_up","ui_down","ui_left","ui_right")
	
	# cuz alreadey rotated y in input
	
	var forward = -transform.basis.z
	var right = transform.basis.x
	
	forward.y = 0 # else the turn happen on y
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()
	
	var direction: Vector3 = (right * input_dir.x+ forward * input_dir.y).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# use "RigidBody3D" to control without setting gravity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y -= (gravity * delta)
	move_and_slide()
