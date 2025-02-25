extends Camera3D

# Debug toggle (local)
var LOCAL_DEBUG: bool = true  # Enable local debugging

@export var player: CharacterBody3D  # The player to follow
@export var camera_distance: float = 4.0  # Distance behind player
@export var camera_height: float = 1.5  # Height above player
@export var rotation_speed: float = 0.05  # Adjust for mouse sensitivity
@export var vertical_limit: float = 75.0  # Limits looking too far up/down

var rotation_x: float = 0.0  # Vertical angle
var rotation_y: float = 0.0  # Horizontal angle
var is_inventory_open: bool = false  # Track inventory state
var stored_rotation_x: float = 0.0  # Store last rotation
var stored_rotation_y: float = 0.0  # Store last rotation

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Locks the cursor for aiming

func _input(event):
	if is_inventory_open:
		return  # Ignore mouse input when inventory is open

	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * rotation_speed  # Left/Right
		rotation_x -= event.relative.y * rotation_speed  # Reversed sign
		rotation_x = clamp(rotation_x, -vertical_limit, vertical_limit)  # Prevents flipping

func set_inventory_open(state: bool):
	is_inventory_open = state
	if is_inventory_open:
		stored_rotation_x = rotation_x  # Save current camera rotation
		stored_rotation_y = rotation_y
	else:
		rotation_x = stored_rotation_x  # Restore previous rotation
		rotation_y = stored_rotation_y

func _process(_delta):
	if player:
		if is_inventory_open:
			return  # Stop camera from updating when inventory is open

		# Camera should stay behind and slightly above the player
		var offset = Vector3(0, camera_height, camera_distance)  # Negative Z moves behind player
		var transform_basis = Basis.from_euler(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))
		var final_position = player.global_transform.origin + transform_basis * offset  # Correct position
		
		# Set new camera position
		self.global_transform.origin = final_position
		
		# Look at the player
		look_at(player.global_transform.origin + Vector3(0, camera_height, 0), Vector3.UP)
