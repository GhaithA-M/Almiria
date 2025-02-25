extends Node3D

@export var tile_size: float = 2.0  # Increased tile size for better walkability
@export var dungeon_width: int = 20  # Increased width
@export var dungeon_height: int = 20  # Increased height
@export var max_side_corridors: int = 5  # Allow more side corridors

var floor_tile = preload("res://Assets/ModularTiles/Floor_Stone.tscn")
var wall_tile = preload("res://Assets/ModularTiles/Wall_Brick.tscn")
var ceiling_tile = preload("res://Assets/ModularTiles/Floor_Stone.tscn")  # Use the floor tile as a ceiling
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

	# Place entrance at the start
	var entrance_instance = entrance_tile.instantiate()
	entrance_instance.transform.origin = Vector3(0, 0, 0)
	add_child(entrance_instance)

	await get_tree().process_frame  # Ensure entrance exists

	# Generate main path and floors
	var path_positions = generate_main_path()
	generate_side_corridors(path_positions)  # Add randomized paths

	# Place boss room at the end
	var boss_instance = boss_room_tile.instantiate()
	boss_instance.transform.origin = path_positions[-1]
	add_child(boss_instance)

	# Generate walls **with proper alignment**
	generate_walls(path_positions)
	generate_ceiling(path_positions)

	# Spawn the player at the entrance
	spawn_player(entrance_instance)

func generate_main_path():
	# Generates a **larger and more randomized** dungeon path
	var path_positions = []
	var current_pos = Vector3(0, 0, 0)
	var directions = [Vector3.RIGHT, Vector3.FORWARD]

	for _i in range(dungeon_width * dungeon_height / 3):  # Ensuring enough path length
		path_positions.append(current_pos)

		var random_dir = directions[randi() % directions.size()]
		var next_pos = current_pos + (random_dir * tile_size)

		if not next_pos in path_positions:
			current_pos = next_pos

		# Place floor tiles **more frequently** to avoid gaps
		for dx in range(3):
			for dz in range(3):
				var expanded_pos = current_pos + Vector3(dx * tile_size / 3, 0, dz * tile_size / 3)
				var floor_instance = floor_tile.instantiate()
				floor_instance.transform.origin = expanded_pos
				add_child(floor_instance)

	return path_positions

func generate_side_corridors(main_path):
	# Create up to max_side_corridors that branch off from the main path
	var side_corridors = 0
	var directions = [Vector3.LEFT, Vector3.RIGHT, Vector3.BACK]

	for pos in main_path:
		if side_corridors >= max_side_corridors:
			break

		if randf() < 0.3:  # 30% chance to create a side corridor
			var branch_dir = directions[randi() % directions.size()]
			var branch_pos = pos + (branch_dir * tile_size)

			if branch_pos not in main_path:
				for dx in range(3):
					for dz in range(3):
						var expanded_pos = branch_pos + Vector3(dx * tile_size / 3, 0, dz * tile_size / 3)
						var floor_instance = floor_tile.instantiate()
						floor_instance.transform.origin = expanded_pos
						add_child(floor_instance)
				side_corridors += 1

func generate_walls(path_positions):
	var wall_positions = {}

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
				wall_instance.scale.y = 5  # Increase wall height

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

func generate_ceiling(path_positions):
	# Cover the dungeon with a ceiling to create an enclosed space
	for pos in path_positions:
		var ceiling_instance = ceiling_tile.instantiate()
		ceiling_instance.transform.origin = pos + Vector3(0, tile_size * 5, 0)
		add_child(ceiling_instance)

func spawn_player(entrance_instance):
	if get_tree().get_nodes_in_group("player").size() == 0:
		var player_instance = player_scene.instantiate()
		player_instance.transform.origin = entrance_instance.global_transform.origin + Vector3(0, 0.5, 0)
		add_child(player_instance)
	else:
		print("⚠️ Player already exists, skipping spawn.")
