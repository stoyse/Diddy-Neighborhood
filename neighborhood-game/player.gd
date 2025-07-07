extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 8.0
@export var gravity := 20.0

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	# Get input direction
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	direction = direction.normalized()
	
	# Apply movement
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()
