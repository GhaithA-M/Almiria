extends Control
class_name InventoryUI

# Debug toggle (local)
var LOCAL_DEBUG: bool = true  # Enable local debugging

# UI elements
@onready var inventory_grid: GridContainer = get_node_or_null("Tabs/EquipmentTab/MainLayout/EquipmentSlots/VBoxContainer")
@onready var slot_template = preload("res://UI/InventorySlotTemplate.tscn")
var inventory: Inventory = null  # Reference to the inventory system

func _ready():
	# Print all children of InventoryUI to confirm node structure
	print("[InventoryUI] Listing all children:")
	for child in get_children():
		print(" - ", child.name)

	# Try to find VBoxContainer
	var path = "Tabs/EquipmentTab/MainLayout/EquipmentSlots/VBoxContainer"
	inventory_grid = get_node_or_null(path)

	if inventory_grid == null:
		push_error("[InventoryUI] ❌ ERROR: VBoxContainer not found at path: " + path)

# Function to update UI when inventory changes
func update_inventory_display():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[InventoryUI] Updating inventory UI...")

	# Add inventory items to UI
	for item in inventory.items:
		var slot = slot_template.duplicate()
		slot.visible = true
		slot.texture = load(item.icon_path)
		slot.tooltip_text = item.name
		inventory_grid.add_child(slot)

	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[InventoryUI] Inventory UI updated with", inventory.items.size(), "items.")
