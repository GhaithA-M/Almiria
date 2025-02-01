extends Node

@export var tilemap: TileMap
@export var width: int = 30
@export var height: int = 30

func _ready():
    generate_dungeon()

func generate_dungeon():
    tilemap.clear()  # Reset old layout
    for x in range(width):
        for y in range(height):
            var tile_type = pick_tile_type(x, y)
            tilemap.set_cell(0, Vector2i(x, y), tile_type, Vector2i(0, 0))
    
    # Add fixed boss room at the end
    place_boss_room()

func pick_tile_type(x, y):
    if x == 0 or y == 0 or x == width-1 or y == height-1:
        return 1  # Walls
    elif randi() % 10 > 7:
        return 2  # Obstacles
    else:
        return 0  # Walkable floor

func place_boss_room():
    var boss_pos = Vector2i(width-5, height-5)
    tilemap.set_cell(0, boss_pos, 3, Vector2i(0, 0))  # Boss door
