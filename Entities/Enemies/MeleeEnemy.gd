extends CharacterBody3D

@export var move_speed: float = 1.5
@export var gravity: float = 9.8
@export var path_update_time: float = 1  # Update path every second

var player: Node3D = null
var last_path_update: float = 0.0
var velocity_y: float = 0.0  # Gravity storage

@onready var health_component: HealthComponent = $Health
@onready var health_bar: HealthBar = $HealthBar if has_node("HealthBar") else null
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var nav_ready: bool = false  # Track if navigation is ready

func _ready():
	find_player()

	# Wait for NavigationServer to sync before setting paths
	NavigationServer3D.map_changed.connect(_on_navigation_ready)

	health_component.died.connect(_on_death)
	health_component.health_changed.connect(_update_health)

	if health_bar:
		health_bar.set_target(self)
		health_bar.visible = GameSettings.healthbar_mode == 2  # Always On
		print("HealthBar set to Always On")
	else:
		print("Warning: HealthBar node not found in MeleeEnemy.tscn")

func _on_navigation_ready(_map_id = null):
	nav_ready = true  # Mark navigation as ready
	print("Navigation system is ready!")

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("Player found:", player)

func _physics_process(delta):
	# Apply gravity
	velocity_y -= gravity * delta
	velocity.y = velocity_y

	if not player or not nav_ready:
		move_and_slide()
		return

	# Update pathfinding every second
	last_path_update += delta
	if last_path_update >= path_update_time:
		last_path_update = 0
		nav_agent.target_position = player.global_position

	# Ensure path exists before trying to follow it
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
	else:
		var next_path_point = nav_agent.get_next_path_position()
		var direction = (next_path_point - global_position).normalized()

		if direction.length() > 0.1:
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed

	move_and_slide()

func take_damage(amount: int):
	print("MeleeEnemy took damage:", amount)
	health_component.take_damage(amount)
	if GameSettings.healthbar_mode == 1:  # Show on Damage
		health_bar.visible = true
		print("HealthBar set to visible (Show on Damage)")
		await get_tree().create_timer(3.0).timeout
		health_bar.visible = false
		print("HealthBar set to invisible after 3 seconds")

func _update_health(new_health: int):
	print("MeleeEnemy health updated to:", new_health)
	if health_bar:
		health_bar.progress_bar.value = new_health
		health_bar.label.text = str(new_health) + " / " + str(health_component.max_health)
		print("HealthBar updated: ", new_health, "/", health_component.max_health)

func _on_death():
	print("Melee Enemy Defeated!")
	queue_free()  # Remove enemy on death
