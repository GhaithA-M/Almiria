extends Node
class_name ItemDatabase

# Debug toggle (local)
var LOCAL_DEBUG: bool = false # Enable local debugging

# Dictionary to store predefined items
var items: Dictionary = {}

func _ready():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Initializing item database...")
	
	_initialize_items()
	
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Item database initialized with %d items." % items.size())


# Function to initialize test items
func _initialize_items():
	var rusty_chestplate = Item.new()
	rusty_chestplate.name = "Rusty Chestplate"
	rusty_chestplate.rarity = "Gray"
	rusty_chestplate.armor = 5
	rusty_chestplate.durability = 1000
	rusty_chestplate.special_effects = ["Thorns"]
	rusty_chestplate.drop_chance = 50.0 # Higher chance for weaker enemies

	var bent_chestplate = Item.new()
	bent_chestplate.name = "Bent Chestplate"
	bent_chestplate.rarity = "Gray"
	bent_chestplate.armor = 10
	bent_chestplate.durability = 1000
	bent_chestplate.special_effects = []
	bent_chestplate.drop_chance = 30.0 # Less common than rusty chestplate

	var old_rifle = Item.new()
	old_rifle.name = "Old Rifle"
	old_rifle.rarity = "Gray"
	old_rifle.damage = 10
	old_rifle.drop_chance = 40.0

	var basic_boots = Item.new()
	basic_boots.name = "Basic Boots"
	basic_boots.rarity = "Gray"
	basic_boots.armor = 3
	basic_boots.durability = 1000
	basic_boots.special_effects = []
	basic_boots.drop_chance = 45.0

	# Store items in dictionary for easy access
	items[rusty_chestplate.name] = rusty_chestplate
	items[bent_chestplate.name] = bent_chestplate
	items[old_rifle.name] = old_rifle
	items[basic_boots.name] = basic_boots

# Function to get an item by name
func get_item(name: String) -> Item:
	if items.has(name):
		return items[name]
	_debug_log("Item not found: %s" % name)
	return null

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1:
		print("[ItemDatabase Debug] ", message)
