extends CharacterBody3D

@export var move_speed: float = 2.5
@export var gravity: float = 9.8
@export var path_update_time: float = 1.0  # Update path every second

var player: Node3D = null
var last_path_update: float = 0.0
var velocity_y: float = 0.0  # Gravity

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	find_player()
	nav_agent.target_position = Vector3(0, 0, 0)  # Force a test path
	print("[DEBUG] Testing path to (0,0,0)")

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("[DEBUG] Found player:", player.name)

func _physics_process(delta):
	# Apply gravity
	velocity_y -= gravity * delta
	velocity.y = velocity_y

	if not player:
		move_and_slide()
		return

	# Update pathfinding every second
	last_path_update += delta
	if last_path_update >= path_update_time:
		last_path_update = 0
		nav_agent.set_target_position(player.global_position)

	# Get the next movement point
	var next_path_point = nav_agent.get_next_path_position()
	var direction = (next_path_point - global_position).normalized()

	if direction.length() > 0.1:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		print("[DEBUG] Attempting Movement - Velocity:", velocity)

	move_and_slide()
