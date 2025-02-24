extends Node
class_name LootTables

# Centralized loot tables for enemy types
var enemy_loot_tables = {
	"MeleeEnemy": ["Rusty Chestplate", "Bent Chestplate", "Basic Boots"]
}

func get_loot(enemy_type: String) -> Array:
	if enemy_loot_tables.has(enemy_type):
		return enemy_loot_tables[enemy_type]
	return []  # Return an empty array if no loot is found
