extends CharacterBody3D

@export var move_speed: float = 1.5
@export var gravity: float = 9.8
@export var path_update_time: float = 0.1

# Debug toggle (local)
var LOCAL_DEBUG: bool = false # Set this to true for local debugging

var player: Node3D = null
var last_path_update: float = 0.0
var velocity_y: float = 0.0

@onready var health_component: HealthComponent = $Health  # Reference to the health component
@onready var health_bar: ProgressBar = $HealthViewport/Control/ProgressBar  # Reference to ProgressBar
@onready var health_sprite: Sprite3D = $HealthSprite3D  # The node for the 3D health bar
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D  # Navigation agent for pathfinding

var nav_ready: bool = false  # Indicates if navigation system is ready

# Fix rotation for health bar
func _ready():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("🔹 MeleeEnemy Ready!")  # Debug: Confirms script is running

	find_player()
	NavigationServer3D.map_changed.connect(_on_navigation_ready)

	if health_component:
		health_component.died.connect(_on_death)  # Connect to the _on_death method
		health_component.health_changed.connect(_update_health)
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("✅ HealthComponent found:", health_component)
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("❌ ERROR: HealthComponent is MISSING!")

	# Health bar visibility setup
	if health_bar:
		health_bar.visible = GameSettings.healthbar_mode == 2  # Show always
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("✅ HealthBar is active")
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("⚠️ Warning: No HealthBar node found!")

	# Health bar positioning above the enemy
	health_sprite.position = Vector3(0, 2.5, 0)  # 2.5 units above the enemy
	# Make health bar face camera initially
	health_sprite.look_at(get_viewport().get_camera_3d().global_transform.origin)

func _on_navigation_ready(_map_id = null):
	nav_ready = true
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("✅ Navigation system ready!")

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("✅ Player detected:", player)
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("❌ No player found!")

func _physics_process(delta):
	velocity_y -= gravity * delta  # Apply gravity
	velocity.y = velocity_y  # Update vertical velocity

	if not player or not nav_ready:
		move_and_slide()
		return

	last_path_update += delta
	if last_path_update >= path_update_time:
		last_path_update = 0
		nav_agent.target_position = player.global_position

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

	# Rotate health bar to face camera smoothly
	health_sprite.look_at(get_viewport().get_camera_3d().global_transform.origin)

func take_damage(amount: int):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("⚔️ MeleeEnemy hit! Damage:", amount)

	if health_component:
		health_component.take_damage(amount)
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("✅ HealthComponent found, applying damage.")
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("❌ ERROR: No HealthComponent found in MeleeEnemy!")

func _update_health(new_health: int):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("💉 Health Updated:", new_health)

	if health_bar:
		health_bar.value = new_health  # Update the health bar value
		health_bar.max_value = health_component.max_health  # Ensure max value is correctly set

		# Change color based on health percentage
		var health_percentage = new_health / float(health_component.max_health)
		if health_percentage > 0.7:
			health_bar.modulate = Color(0, 1, 0)  # Green for high health
		elif health_percentage > 0.3:
			health_bar.modulate = Color(1, 1, 0)  # Yellow for medium health
		else:
			health_bar.modulate = Color(1, 0, 0)  # Red for low health

		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("✅ HealthBar updated:", new_health, "/", health_component.max_health)

# Declare the _on_death method to handle when health reaches zero
func _on_death():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("💀 MeleeEnemy defeated! Dropping loot.")

	var loot_manager = get_tree().get_first_node_in_group("loot_manager")
	
	if loot_manager == null:
		if DebugSettings.DEBUG_MODE == 1 or LOCAL_DEBUG:
			print("❌ ERROR: LootManager not found!")
		queue_free()  # Still remove enemy to avoid game-breaking issues
		return

	var dropped_item = loot_manager.get_loot("MeleeEnemy")

	if dropped_item:
		loot_manager.spawn_loot(dropped_item, global_transform.origin)

	queue_free()  # Remove the enemy after death
