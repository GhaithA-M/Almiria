extends CharacterBody3D

const SPEED = 2
const SPRINT_MULTIPLIER = 2 # Multiplier for sprinting speed
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var local_velocity = Vector3.ZERO
var offset: Vector3 = Vector3(0, 0, 0)

# Bullets
var bullet = load("res://Entities/WeaponProjectile1.tscn")
var instance

@onready var gun_anim = $FullAuto1/AnimationPlayer
@onready var gun_barrel = $FullAuto1/RayCast3D

func _physics_process(delta):
	local_velocity = velocity

	if not is_on_floor():
		local_velocity.y -= gravity * delta

	var input_dir = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
							Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"))
	var direction = Vector3(input_dir.x, 0, -input_dir.y)
	var current_speed = SPEED
	
		# Check if shift key is pressed for sprinting
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= SPRINT_MULTIPLIER
	
	if direction != Vector3.ZERO:
		local_velocity.x = direction.x * current_speed
		local_velocity.z = direction.z * current_speed
	else:
		# Multiply by variable (3) for deceleration, higher number reduces slide
		local_velocity.x = lerp(local_velocity.x, 0.0, (SPEED * delta * 3))
		local_velocity.z = lerp(local_velocity.z, 0.0, (SPEED * delta * 3))

	self.velocity = local_velocity
	move_and_slide()
	
# Shooting
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
	
	var target_position = ScreenPointToRay()
	if target_position != Vector3.ZERO:
		target_position.y = global_transform.origin.y  # Ignore vertical difference
		look_at(target_position, Vector3.UP)

# Function to convert screen point to a ray in 3D space
func ScreenPointToRay():
	# Get the current physics state
	var spaceState = get_world_3d().get_direct_space_state()
	
	# Get the current mouse position in the viewport
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Get the current camera in the viewport
	var camera = get_viewport().get_camera_3d()
	
	# Calculate the ray origin by projecting the mouse position into 3D space
	var rayOrigin = camera.project_ray_origin(mouse_pos)
	
	# Calculate the ray end point by adding the projected normal of the mouse position to the ray origin
	var rayEnd = rayOrigin + camera.project_ray_normal(mouse_pos) * 2000
	
	# Perform a ray intersection query using the ray origin and end point
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd))
	
	# If the ray intersection query has a position (it hit something), return that position
	if rayArray.has("position"):
		return rayArray["position"]
	# If the ray intersection query did not hit anything, return a zero vector
	return Vector3()
