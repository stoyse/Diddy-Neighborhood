extends CharacterBody3D

@export var speed := 5.0
@export var vision_range := 20.0
@export var field_of_view_degrees := 90.0

var player: Node3D = null

func _ready():
	player = get_node_or_null("/root/World/Player")  # Adjust path as needed

func _physics_process(delta):
	if player and can_see_player():
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		move_and_slide()

func can_see_player() -> bool:
	var to_player = player.global_transform.origin - global_transform.origin
	if to_player.length() > vision_range:
		return false

	# Check FOV
	var forward = -global_transform.basis.z.normalized()
	var angle = rad_to_deg(forward.angle_to(to_player.normalized()))
	if angle > field_of_view_degrees / 2.0:
		return false

	# Line of sight check using PhysicsRayQueryParameters3D
	var ray_params = PhysicsRayQueryParameters3D.create(global_transform.origin, player.global_transform.origin)
	ray_params.exclude = [self]
	
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	if result and result.collider != player:
		return false

	return true
