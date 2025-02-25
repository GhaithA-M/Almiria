extends Resource
class_name DungeonConfig

# General dungeon settings
@export var tile_size: float = 0.5
@export var dungeon_width: int = 40
@export var dungeon_height: int = 40
@export var max_side_corridors: int = 3

# Preloaded assets
@export var floor_tile: PackedScene
@export var wall_tile: PackedScene
@export var entrance_tile: PackedScene
@export var boss_room_tile: PackedScene
@export var player_scene: PackedScene
