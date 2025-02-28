extends Node3D

@export var tile_size: float = 2.0
@export var dungeon_width: int = 20
@export var dungeon_height: int = 20
@export var max_side_corridors: int = 5

var floor_tile = preload("res://Assets/ModularTiles/Floor_Stone.tscn")
var wall_tile = preload("res://Assets/ModularTiles/Wall_Brick.tscn")
var ceiling_tile = preload("res://Assets/ModularTiles/Floor_Stone.tscn")
var entrance_tile = preload("res://Assets/ModularTiles/Entrance.tscn")
var boss_room_tile = preload("res://Assets/ModularTiles/BossRoom.tscn")
var player_scene = preload("res://Entities/Player/Player.tscn")

# Track positions for later reference
var floor_positions = []
var entrance_position = Vector3.ZERO
var boss_position = Vector3.ZERO

func _ready():
	generate_dungeon()

func generate_dungeon():
	# Clear existing dungeon elements
	for child in get_children():
		if not child.is_in_group("player"):
			child.queue_free()
	
	# Reset tracking
	floor_positions.clear()
	entrance_position = Vector3.ZERO

	# Create entrance area
	create_entrance_area()
	
	# Generate main path from entrance to boss room
	var path_positions = generate_main_path()
	
	# Create boss room at the end
	create_boss_room(path_positions[path_positions.size() - 1])
	
	# Generate side corridors for exploration
	generate_side_corridors(path_positions)
	
	# Generate walls around the floor areas
	generate_walls()
	
	# Generate ceiling over the floor areas
	generate_ceiling()
	
	# Spawn player at entrance
	spawn_player()

func create_entrance_area():
	# Create entrance at the origin
	entrance_position = Vector3.ZERO
	
	# Place entrance tile
	var entrance_instance = entrance_tile.instantiate()
	entrance_instance.transform.origin = entrance_position
	add_child(entrance_instance)
	
	# Create a 5x5 entrance area with densely packed tiles
	for x in range(-4, 5):
		for z in range(-4, 5):
			var pos = Vector3(x * tile_size / 3, 0, z * tile_size / 3)
			if not floor_positions.has(pos):
				floor_positions.append(pos)
				var floor_instance = floor_tile.instantiate()
				floor_instance.transform.origin = pos
				add_child(floor_instance)

func create_boss_room(position):
	boss_position = position
	
	# Place boss room tile
	var boss_instance = boss_room_tile.instantiate()
	boss_instance.transform.origin = boss_position
	add_child(boss_instance)
	
	# Create a 5x5 boss area with densely packed tiles
	for x in range(-4, 5):
		for z in range(-4, 5):
			var pos = boss_position + Vector3(x * tile_size / 3, 0, z * tile_size / 3)
			if not floor_positions.has(pos):
				floor_positions.append(pos)
				var floor_instance = floor_tile.instantiate()
				floor_instance.transform.origin = pos
				add_child(floor_instance)

func generate_main_path():
	var path = []
	var current_pos = Vector3(tile_size, 0, 0)  # Start adjacent to entrance area
	
	# Mark starting position
	path.append(current_pos)
	
	# Direction starts toward right (X axis)
	var current_direction = Vector3.RIGHT
	var path_length = 15  # Controlled length
	
	for _i in range(path_length):
		# Determine whether to change direction
		if randf() < 0.3 and _i > 2:  # 30% chance to change direction after first few steps
			# Choose between turning left/right or continuing straight
			var possible_directions = []
			
			if current_direction == Vector3.RIGHT or current_direction == Vector3.LEFT:
				possible_directions = [Vector3.FORWARD, Vector3.BACK]
			else:
				possible_directions = [Vector3.RIGHT, Vector3.LEFT]
			
			current_direction = possible_directions[randi() % possible_directions.size()]
		
		# Calculate next position
		var next_pos = current_pos + (current_direction * tile_size)
		
		# Create continuous path (no gaps between tiles)
		current_pos = next_pos
		path.append(current_pos)
		
		# Create dense floor tiles in a rectangular area along the path
		for dx in range(-3, 4):
			for dz in range(-3, 4):
				var offset_dir
				var perpendicular_dir
				
				if current_direction.x != 0:  # Moving along X axis
					offset_dir = Vector3(current_direction.x / 3, 0, 0)
					perpendicular_dir = Vector3(0, 0, 1)
				else:  # Moving along Z axis
					offset_dir = Vector3(0, 0, current_direction.z / 3)
					perpendicular_dir = Vector3(1, 0, 0)
				
				var expanded_pos = current_pos + (perpendicular_dir * dx * tile_size / 3) + (offset_dir * dz)
				
				if not floor_positions.has(expanded_pos):
					floor_positions.append(expanded_pos)
					var floor_instance = floor_tile.instantiate()
					floor_instance.transform.origin = expanded_pos
					add_child(floor_instance)
	
	# Set final position as target for boss room
	boss_position = current_pos + (current_direction * tile_size * 2)
	path.append(boss_position)
	
	return path

func generate_side_corridors(main_path):
	var side_corridors_created = 0
	var main_path_without_ends = main_path.duplicate()
	
	# Don't start side corridors from the beginning or end of main path
	if main_path_without_ends.size() > 2:
		main_path_without_ends.pop_front()
		main_path_without_ends.pop_back()
		main_path_without_ends.shuffle()
	
	for pos in main_path_without_ends:
		if side_corridors_created >= max_side_corridors:
			break
		
		# Try all four directions
		var directions = [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
		directions.shuffle()
		
		for dir in directions:
			var corridor_length = randi_range(3, 6)
			var valid_corridor = true
			var corridor_positions = []
			
			# Check if we can build a corridor in this direction
			for i in range(1, corridor_length + 1):
				var check_pos = pos + (dir * tile_size * i)
				
				# Skip if too close to existing path
				for existing_pos in main_path:
					if existing_pos.distance_to(check_pos) < tile_size:
						valid_corridor = false
						break
				
				if not valid_corridor:
					break
					
				corridor_positions.append(check_pos)
			
			if valid_corridor and corridor_positions.size() > 0:
				# Create the corridor with dense tile placement
				for corridor_pos in corridor_positions:
					# Create a wide corridor with densely packed tiles
					for dx in range(-3, 4):
						for dz in range(-3, 4):
							var perpendicular_dir
							var offset_dir
							
							if dir.x != 0:  # Moving along X axis
								perpendicular_dir = Vector3(0, 0, 1)
								offset_dir = Vector3(dir.x / 3, 0, 0)
							else:  # Moving along Z axis
								perpendicular_dir = Vector3(1, 0, 0)
								offset_dir = Vector3(0, 0, dir.z / 3)
							
							var expanded_pos = corridor_pos + (perpendicular_dir * dx * tile_size / 3) + (offset_dir * dz)
							
							if not floor_positions.has(expanded_pos):
								floor_positions.append(expanded_pos)
								var floor_instance = floor_tile.instantiate()
								floor_instance.transform.origin = expanded_pos
								add_child(floor_instance)
				
				side_corridors_created += 1
				break

func generate_walls():
	var wall_positions = {}
	var check_directions = [
		Vector3.RIGHT,
		Vector3.LEFT, 
		Vector3.FORWARD,
		Vector3.BACK
	]
	
	# Check around each floor tile for potential wall positions
	for floor_pos in floor_positions:
		for dir in check_directions:
			var wall_pos = floor_pos + (dir * tile_size / 2)
			
			# Check if this wall position would be at the edge of the floor
			var adjacent_pos = floor_pos + (dir * tile_size)
			if not floor_positions.has(adjacent_pos):
				# Only place a wall if we don't already have one here
				var wall_key = str(wall_pos.x) + "_" + str(wall_pos.z)
				if not wall_positions.has(wall_key):
					wall_positions[wall_key] = dir
	
	# Place walls at all identified positions
	for wall_key in wall_positions.keys():
		var dir = wall_positions[wall_key]
		var coords = wall_key.split("_")
		var wall_pos = Vector3(float(coords[0]), 0, float(coords[1]))
		
		var wall_instance = wall_tile.instantiate()
		wall_instance.transform.origin = wall_pos
		
		# Set wall rotation based on the direction it's facing
		if dir == Vector3.RIGHT:
			wall_instance.rotation_degrees.y = 90
		elif dir == Vector3.LEFT:
			wall_instance.rotation_degrees.y = -90
		elif dir == Vector3.FORWARD:
			wall_instance.rotation_degrees.y = 0
		elif dir == Vector3.BACK:
			wall_instance.rotation_degrees.y = 180
		
		# Make walls tall enough
		wall_instance.scale.y = 5.0
		
		add_child(wall_instance)

func generate_ceiling():
	# Place ceiling tiles directly above each floor tile
	var ceiling_positions = []
	
	for floor_pos in floor_positions:
		var ceiling_pos = floor_pos + Vector3(0, 8.0, 0)
		
		# Check if we already have a ceiling at this position
		if not ceiling_positions.has(ceiling_pos):
			ceiling_positions.append(ceiling_pos)
			var ceiling_instance = ceiling_tile.instantiate()
			ceiling_instance.transform.origin = ceiling_pos
			
			# Flip ceiling tiles to face downward
			ceiling_instance.rotation_degrees.x = 180
			
			add_child(ceiling_instance)

func spawn_player():
	if get_tree().get_nodes_in_group("player").size() == 0:
		var player_instance = player_scene.instantiate()
		
		# Position player at entrance
		player_instance.transform.origin = entrance_position + Vector3(0, 1.0, 0)
		player_instance.add_to_group("player")
		add_child(player_instance)
	else:
		print("⚠️ Player already exists, skipping spawn.")
