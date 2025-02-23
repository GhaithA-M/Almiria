extends Camera3D

@export var player: CharacterBody3D  # The player to follow
@export var camera_distance: float = 4.0  # Distance behind player
@export var camera_height: float = 1.5  # Height above player
@export var rotation_speed: float = 0.1  # Adjust for mouse sensitivity
@export var vertical_limit: float = 75.0  # Limits looking too far up/down

var rotation_x: float = 0.0  # Vertical angle
var rotation_y: float = 0.0  # Horizontal angle

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Locks the cursor for aiming

func _input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * rotation_speed  # Left/Right
		rotation_x -= event.relative.y * rotation_speed  # Reversed sign
		rotation_x = clamp(rotation_x, -vertical_limit, vertical_limit)  # Prevents flipping

func _process(_delta):
	if player:
		# Camera should stay behind and slightly above the player
		var offset = Vector3(0, camera_height, camera_distance)  # Negative Z moves behind player
		var transform_basis = Basis.from_euler(Vector3(deg_to_rad(rotation_x), deg_to_rad(rotation_y), 0))
		var final_position = player.global_transform.origin + transform_basis * offset  # Correct position
		
		# Set new camera position
		self.global_transform.origin = final_position
		
		# Look at the player
		look_at(player.global_transform.origin + Vector3(0, camera_height, 0), Vector3.UP)
