extends Node3D

@export var tile_size: float = 1.0  # Adjusted for 1x1m tiles
@export var dungeon_width: int = 10
@export var dungeon_height: int = 10

var floor_tile = preload("res://Assets/ModularTiles/Floor_Stone.tscn")
var wall_tile = preload("res://Assets/ModularTiles/Wall_Brick.tscn")
var entrance_tile = preload("res://Assets/ModularTiles/Entrance.tscn")
var boss_room_tile = preload("res://Assets/ModularTiles/BossRoom.tscn")

func _ready():
	generate_dungeon()

func generate_dungeon():
	# Place static entrance at (0,0,0)
	var entrance_instance = entrance_tile.instantiate()
	entrance_instance.transform.origin = Vector3(0, 0, 0)
	add_child(entrance_instance)
	
	# Generate main dungeon
	for x in range(1, dungeon_width - 1):
		for z in range(1, dungeon_height - 1):
			var floor_instance = floor_tile.instantiate()
			floor_instance.transform.origin = Vector3(x * tile_size, 0, z * tile_size)
			add_child(floor_instance)

			if randi() % 5 == 0:  # Randomly place walls
				var wall_instance = wall_tile.instantiate()
				wall_instance.transform.origin = Vector3(x * tile_size, 0.1, z * tile_size)  # Adjusted for 0.2 thickness
				add_child(wall_instance)
	
	# Place static boss room at the end
	var boss_instance = boss_room_tile.instantiate()
	boss_instance.transform.origin = Vector3((dungeon_width - 2) * tile_size, 0, (dungeon_height - 2) * tile_size)
	add_child(boss_instance)
