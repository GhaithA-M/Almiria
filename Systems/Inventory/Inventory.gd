extends Node
class_name Inventory

# Inventory properties
var items: Array = [] # List to store items
var max_slots: int = 20 # Maximum inventory capacity

# Debug toggle (global and local)
var LOCAL_DEBUG: bool = false # Enable local debugging

# Function to add an item to inventory
func add_item(item: Item):
	if items.size() < max_slots:
		items.append(item)
		_debug_log("Added item: %s" % item.name)
	else:
		_debug_log("Inventory is full! Cannot add %s" % item.name)

# Function to remove an item from inventory
func remove_item(item: Item):
	if item in items:
		items.erase(item)
		_debug_log("Removed item: %s" % item.name)
	else:
		_debug_log("Item not found: %s" % item.name)

# Function to check if inventory has a specific item
func has_item(item_name: String) -> bool:
	for item in items:
		if item.name == item_name:
			return true
	return false

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[Inventory Debug] ", message)

# Function to print all inventory items
func print_inventory():
	var item_names = []
	for item in items:
		item_names.append(item.name)
	_debug_log("Inventory contains: " + ", ".join(item_names))
