extends CharacterBody3D

const SPEED = 4
const SPRINT_MULTIPLIER = 2  # Multiplier for sprinting speed
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var local_velocity = Vector3.ZERO
var offset: Vector3 = Vector3(0, 0, 0)

# Bullets
var bullet = load("res://Entities/Weapons/WeaponProjectile1.tscn")
var instance

@export var camera: Camera3D  # Make sure this is assigned in the Inspector

@onready var gun_anim = $FullAutoRifle1/AnimationPlayer
@onready var gun_barrel = $FullAutoRifle1/RayCast3D

func _physics_process(delta):
	local_velocity = velocity

	if not is_on_floor():
		local_velocity.y -= gravity * delta

	var input_dir = Vector2(
		Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var current_speed = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= SPRINT_MULTIPLIER

	# **Fix: Movement relative to player's facing direction**
	if input_dir.length() > 0:
		# Get the player's forward and right direction
		var forward = -global_transform.basis.z.normalized()  # Player's forward direction
		var right = global_transform.basis.x.normalized()  # Player's right direction
		
		# Calculate movement direction relative to the player's facing direction
		var move_dir = (forward * input_dir.y + right * input_dir.x).normalized()
		local_velocity.x = move_dir.x * current_speed
		local_velocity.z = move_dir.z * current_speed
		
		# Rotate the player to match movement direction
		var target_rotation = atan2(-move_dir.x, -move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 10)  # Smooth rotation
	else:
		# Smooth stopping when no input is given
		local_velocity.x = lerp(local_velocity.x, 0.0, SPEED * delta * 3)
		local_velocity.z = lerp(local_velocity.z, 0.0, SPEED * delta * 3)

	self.velocity = local_velocity
	move_and_slide()
	
	# **Shooting**
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

# **Fix: Raycasting for Aiming**
func ScreenPointToRay():
	var spaceState = get_world_3d().get_direct_space_state()
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var rayOrigin = camera.project_ray_origin(mouse_pos)
	var rayEnd = rayOrigin + camera.project_ray_normal(mouse_pos) * 2000
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd))
	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3()

func _ready():
	add_to_group("player")
