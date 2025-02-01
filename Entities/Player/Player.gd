extends CharacterBody3D

@onready var health_component: HealthComponent = $Health
@onready var health_bar: HealthBar = $HealthBar if has_node("HealthBar") else null

const SPEED = 2
const SPRINT_MULTIPLIER = 2
var gravity: float = 0.0
var local_velocity: Vector3 = Vector3.ZERO

var bullet = load("res://Entities/Weapons/WeaponProjectile1.tscn")
var instance

@onready var gun_anim = $FullAutoRifle1/AnimationPlayer
@onready var gun_barrel = $FullAutoRifle1/RayCast3D

func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	add_to_group("player")
	health_component.died.connect(_on_death)
	health_component.health_changed.connect(_update_health)

	# Ensure health bar is properly assigned
	if health_bar:
		health_bar.set_target(self)
		health_bar.visible = GameSettings.healthbar_mode == 2  # Always On
	else:
		print("Warning: HealthBar node not found in Player.tscn")

func _physics_process(delta: float):
	local_velocity = velocity

	if not is_on_floor():
		local_velocity.y -= gravity * delta

	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	)
	var direction = Vector3(input_dir.x, 0, -input_dir.y)
	var current_speed = SPEED

	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= SPRINT_MULTIPLIER

	if direction != Vector3.ZERO:
		local_velocity.x = direction.x * current_speed
		local_velocity.z = direction.z * current_speed
	else:
		local_velocity.x = lerp(local_velocity.x, 0.0, (SPEED * delta * 3))
		local_velocity.z = lerp(local_velocity.z, 0.0, (SPEED * delta * 3))

	self.velocity = local_velocity
	move_and_slide()

	if Input.is_action_pressed("shoot"):
		_fire_weapon()

	var target_position = _screen_point_to_ray()
	if target_position != Vector3.ZERO:
		target_position.y = global_transform.origin.y
		look_at(target_position, Vector3.UP)

func _fire_weapon():
	if !gun_anim.is_playing():
		gun_anim.play("Shoot")
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)

func take_damage(amount: int):
	health_component.take_damage(amount)
	if GameSettings.healthbar_mode == 1:  # Show on Damage
		health_bar.visible = true
		await get_tree().create_timer(3.0).timeout
		health_bar.visible = false

func _update_health(new_health: int):
	if health_bar:
		health_bar.progress_bar.value = new_health
		health_bar.label.text = str(new_health) + " / " + str(health_component.max_health)

func _on_death():
	print("Player died! Losing durability...")
	DurabilityManager.reduce_durability()

func _screen_point_to_ray():
	var space_state = get_world_3d().get_direct_space_state()
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	var ray_query = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))
	
	if ray_query.has("position"):
		return ray_query["position"]
	return Vector3()
