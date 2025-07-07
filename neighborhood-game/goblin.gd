extends CharacterBody3D

@export var speed := 5.0
@export var vision_range := 20.0
@export var field_of_view_degrees := 90.0

var player: Node3D = null

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("✅ Player found: ", player.name)
	else:
		push_error("❌ No player found in 'player' group.")

func _physics_process(delta):
	if player and can_see_player():
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * speed
		print("👀 Player seen — moving toward them.")
	else:
		velocity = Vector3.ZERO
		print("🚫 Player not seen — staying idle.")

	move_and_slide()

func can_see_player() -> bool:
	var to_player = player.global_transform.origin - global_transform.origin
	var distance = to_player.length()

	print("📏 Distance to player: ", distance)

	if distance > vision_range:
		print("❌ Player out of vision range.")
		return false

	# Check Field of View
	var forward = -global_transform.basis.z.normalized()
	var angle = rad_to_deg(forward.angle_to(to_player.normalized()))
	print("🎯 Angle to player: ", angle)

	if angle > field_of_view_degrees / 2.0:
		print("❌ Player out of field of view.")
		return false

	# Line-of-sight raycast
	var space_state = get_world_3d().direct_space_state
	var ray_params := PhysicsRayQueryParameters3D.new()
	ray_params.from = global_transform.origin
	ray_params.to = player.global_transform.origin
	ray_params.exclude = [self]

	var result = space_state.intersect_ray(ray_params)
	if result:
		if result.collider != player:
			print("❌ Line of sight blocked by: ", result.collider.name)
			return false
		else:
			print("✅ Line of sight confirmed.")
	else:
		print("⚠️ No collision detected — assuming line of sight clear.")

	return true
