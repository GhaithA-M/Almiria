extends Resource
class_name Item

# Item properties
var name: String = "Unknown Item" # Name of the item
var rarity: String = "Gray" # Rarity type: Gray, Blue, Yellow, etc.
var armor: int = 0 # Armor value (only for armor pieces)
var damage: int = 0 # Damage value (for weapons, if needed later)
var durability: int = 1000 # Armor durability (only for armor)
var drop_chance: float = 1.0 # Base drop rate, adjusted per enemy type
var special_effects: Array = [] # List of effects (e.g., "Thorns")

# Debug toggle (local)
var LOCAL_DEBUG: bool = false # Set this to true for local debugging

# Function to decrease durability on hit
func decrease_durability_on_hit():
	if durability > 0:
		durability -= 1 # Reduce durability by 1 per hit
		_debug_log("Durability decreased by 1 (%.1f%% left)" % (_get_durability_percentage()))
		if durability <= 0:
			_handle_broken_armor()

# Function to decrease durability on death
func decrease_durability_on_death():
	if durability > 0:
		durability -= 10 # Reduce by 10 per death
		_debug_log("Durability decreased by 10 (%.1f%% left)" % (_get_durability_percentage()))
		if durability <= 0:
			_handle_broken_armor()

# Function to check durability percentage
func _get_durability_percentage() -> float:
	return (durability / 1000.0) * 100

# Function to handle broken armor
func _handle_broken_armor():
	durability = 0 # Ensure it stays at zero
	_debug_log("Armor is now broken and provides no stats.")

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 or LOCAL_DEBUG:
		print("[Item Debug] ", message)

# Example debug function to print item details
func print_item_details():
	_debug_log("Name: %s | Rarity: %s | Armor: %d | Durability: %d (%.1f%%)" % [name, rarity, armor, durability, _get_durability_percentage()])
