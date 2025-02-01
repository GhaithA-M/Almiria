extends Node3D

@export var tile_size: float = 1.0  # 1x1m tiles
@export var dungeon_width: int = 20  # Increased width
@export var dungeon_height: int = 20  # Increased height
@export var max_side_corridors: int = 3  # Maximum number of side corridors

var floor_tile = preload("res://Assets/ModularTiles/Floor_Stone.tscn")
var wall_tile = preload("res://Assets/ModularTiles/Wall_Brick.tscn")
var entrance_tile = preload("res://Assets/ModularTiles/Entrance.tscn")
var boss_room_tile = preload("res://Assets/ModularTiles/BossRoom.tscn")
var player_scene = preload("res://Entities/Player/Player.tscn")

func _ready():
	generate_dungeon()

func generate_dungeon():
	# Clear existing dungeon elements
	for child in get_children():
		if not child.is_in_group("player"):
			child.queue_free()
	
	# Place entrance at the bottom-left corner
	var entrance_instance = entrance_tile.instantiate()
	entrance_instance.transform.origin = Vector3(0, 0, 0)
	add_child(entrance_instance)
	
	await get_tree().process_frame  # Ensure entrance exists

	# Generate main path and floors
	var path_positions = generate_main_path()
	generate_side_corridors(path_positions)  # Add blind alleys

	# Spawn the player after everything is in place
	spawn_player(entrance_instance)

	# Place boss room **farther from the entrance**
	var boss_instance = boss_room_tile.instantiate()
	boss_instance.transform.origin = path_positions[-1]  # Boss at the **farthest main path position**
	add_child(boss_instance)

	# Generate walls **with proper rotation**
	generate_walls(path_positions)

func generate_main_path():
	# Generates a **longer, more structured** dungeon path
	var current_x = 1
	var current_z = 1
	var path_positions = [Vector3(0, 0, 0)]  # Start from entrance

	while current_x < dungeon_width - 5 or current_z < dungeon_height - 5:
		var move_horizontal = randf() > 0.5  # 50% chance to move right, 50% to move forward
		if move_horizontal and current_x < dungeon_width - 5:
			current_x += 1
		elif current_z < dungeon_height - 5:
			current_z += 1
		
		var new_pos = Vector3(current_x * tile_size, 0, current_z * tile_size)
		path_positions.append(new_pos)

		# Create a floor tile at this position
		var floor_instance = floor_tile.instantiate()
		floor_instance.transform.origin = new_pos
		add_child(floor_instance)

	return path_positions

func generate_side_corridors(main_path):
	# Create up to max_side_corridors that branch off from the main path
	var side_corridors = 0

	for i in range(main_path.size() - 2):  # Avoid entrance/boss room area
		if side_corridors >= max_side_corridors:
			break

		if randf() < 0.5:  # 50% chance to create a side corridor
			var branch_direction = Vector3.RIGHT if randf() > 0.5 else Vector3.FORWARD
			var branch_pos = main_path[i] + (branch_direction * tile_size)

			# Ensure the side corridor doesn't overwrite the main path
			if branch_pos not in main_path:
				var floor_instance = floor_tile.instantiate()
				floor_instance.transform.origin = branch_pos
				add_child(floor_instance)
				side_corridors += 1

func generate_walls(path_positions):
	var wall_positions = {}

	# Surround all floor tiles with walls **AND rotate them properly**
	for pos in path_positions:
		var directions = {
			"left": Vector3.LEFT,
			"right": Vector3.RIGHT,
			"forward": Vector3.FORWARD,
			"back": Vector3.BACK
		}

		for dir_name in directions.keys():
			var dir = directions[dir_name]
			var wall_pos = pos + (dir * tile_size)
			if wall_pos not in path_positions and wall_pos not in wall_positions:
				wall_positions[wall_pos] = true
				var wall_instance = wall_tile.instantiate()
				wall_instance.transform.origin = wall_pos

				# Rotate the walls properly to face the open area
				match dir_name:
					"left":
						wall_instance.rotation_degrees.y = 90
					"right":
						wall_instance.rotation_degrees.y = -90
					"forward":
						wall_instance.rotation_degrees.y = 0
					"back":
						wall_instance.rotation_degrees.y = 180

				add_child(wall_instance)

func spawn_player(entrance_instance):
	if get_tree().get_nodes_in_group("player").size() == 0:
		var player_instance = player_scene.instantiate()
		player_instance.transform.origin = entrance_instance.global_transform.origin + Vector3(0, 0.5, 0)
		add_child(player_instance)

		await get_tree().process_frame  # Wait a frame before initializing player components
		print("✅ Player spawned successfully at entrance.")
	else:
		print("⚠️ Player already exists, skipping spawn.")
