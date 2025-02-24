extends Node
class_name LootManager

# Reference to the item database and loot tables
@onready var item_database = get_tree().get_first_node_in_group("item_database")
@onready var inventory = get_tree().get_first_node_in_group("inventory")
@onready var loot_table_manager = get_tree().get_first_node_in_group("loot_tables")

# Debug toggle (local)
var LOCAL_DEBUG: bool = false # Enable local debugging

func _ready():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootManager Debug] Initialized LootManager")
	
	if item_database == null:
		_debug_log("❌ ERROR: ItemDatabase not found!")
	if inventory == null:
		_debug_log("❌ ERROR: Inventory system not found!")
	if loot_table_manager == null:
		_debug_log("❌ ERROR: LootTables system not found!")

# Function to determine loot drop for a specific enemy
func get_loot(enemy_type: String) -> Item:
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Fetching loot for enemy: %s" % enemy_type)
	
	if item_database == null or loot_table_manager == null:
		_debug_log("❌ ERROR: Cannot get loot - ItemDatabase or LootTables is null!")
		return null
	
	var possible_loot_names = loot_table_manager.get_loot(enemy_type)
	if possible_loot_names.is_empty():
		_debug_log("No loot available for enemy type: %s" % enemy_type)
		return null
	
	var possible_loot = []
	for item_name in possible_loot_names:
		possible_loot.append(item_database.get_item(item_name))
	
	return _roll_for_loot(possible_loot)

# Function to roll for loot based on drop chance
func _roll_for_loot(possible_loot: Array) -> Item:
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Rolling for loot drop")
	
	var roll = randf() * 100
	for item in possible_loot:
		if roll <= item.drop_chance:
			_debug_log("Dropped item: %s" % item.name)
			return item
	_debug_log("No item dropped.")
	return null

# Function to spawn the loot in the world
func spawn_loot(item: Item, position: Vector3):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Spawning loot: %s at position %s" % [item.name, position])
	
	if item == null:
		return
	
	await get_tree().process_frame  # Ensure the item is properly inside the scene tree before spawning
	
	if not is_inside_tree():
		_debug_log("⚠️ LootManager is not inside the tree yet, retrying...")
		await get_tree().process_frame
		if not is_inside_tree():
			_debug_log("❌ ERROR: LootManager still not inside the tree. Aborting loot spawn.")
			return
	
	var loot_scene = preload("res://Entities/Equipment/LootItem.tscn")
	var loot_instance = loot_scene.instantiate()
	loot_instance.set_item(item)
	loot_instance.global_transform.origin = position
	get_parent().add_child(loot_instance)
	_debug_log("✅ Spawned loot: %s at position %s" % [item.name, position])

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootManager Debug] ", message)
