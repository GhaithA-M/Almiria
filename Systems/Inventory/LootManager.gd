extends Node
class_name LootManager

# Reference to the item database
@onready var item_database = null

# Debug toggle (global and local)
var LOCAL_DEBUG: bool = false # Enable local debugging

func _ready():
	item_database = get_tree().get_first_node_in_group("item_database")
	if item_database == null:
		_debug_log("❌ ERROR: ItemDatabase not found!")

# Function to determine loot drop for a specific enemy
func get_loot(enemy_type: String) -> Item:
	if item_database == null:
		_debug_log("❌ ERROR: Cannot get loot - ItemDatabase is null!")
		return null

	var loot_table = {
		"MeleeEnemy": [
			item_database.get_item("Rusty Chestplate"),
			item_database.get_item("Bent Chestplate"),
			item_database.get_item("Basic Boots")
		]
	}
	
	if loot_table.has(enemy_type):
		var possible_loot = loot_table[enemy_type]
		var chosen_loot = _roll_for_loot(possible_loot)
		return chosen_loot
	
	_debug_log("No loot available for enemy type: %s" % enemy_type)
	return null

# Function to roll for loot based on drop chance
func _roll_for_loot(possible_loot: Array) -> Item:
	var roll = randf() * 100
	for item in possible_loot:
		if roll <= item.drop_chance:
			_debug_log("Dropped item: %s" % item.name)
			return item
	_debug_log("No item dropped.")
	return null

# Function to spawn the loot in the world
func spawn_loot(item: Item, position: Vector3):
	if item == null:
		return
	var loot_scene = preload("res://Entities/Equipment/LootItem.tscn")
	var loot_instance = loot_scene.instantiate()
	loot_instance.set_item(item)
	loot_instance.global_transform.origin = position
	get_parent().add_child(loot_instance)
	_debug_log("Spawned loot: %s at position %s" % [item.name, position])

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 or LOCAL_DEBUG:
		print("[LootManager Debug] ", message)
