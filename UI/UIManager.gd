extends Node

# Debug toggle (local)
var LOCAL_DEBUG: bool = true  # Enable local debugging

var inventory_ui: Control  # Declare the variable

func _ready() -> void:
	inventory_ui = get_node_or_null("InventoryUI")  # Use `get_node_or_null` to avoid crashes
	if inventory_ui:
		inventory_ui.visible = false  # Start hidden
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] InventoryUI found. Setting visible = false.")
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] ERROR: InventoryUI not found!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] toggle_inventory key pressed.")
		toggle_inventory()

func toggle_inventory() -> void:
	if inventory_ui:
		inventory_ui.visible = !inventory_ui.visible
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] Toggled InventoryUI. Now visible:", inventory_ui.visible)

		if inventory_ui.visible:
			if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
				print("[UIManager] Unlocking mouse pointer & pausing player controls.")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Show mouse
			get_tree().paused = true  # **Pauses game logic (fixes wild aiming)**
		else:
			if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
				print("[UIManager] Locking mouse pointer & resuming player controls.")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Lock mouse back in
			get_tree().paused = false  # **Resumes game logic**
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] ERROR: InventoryUI is null!")
