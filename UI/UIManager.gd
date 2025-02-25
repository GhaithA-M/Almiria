extends Node

# Debug toggle (local)
var LOCAL_DEBUG: bool = false  # Enable local debugging

@onready var inventory_ui: Control = get_node("InventoryUI")  # Use the same method as before
@onready var camera: Camera3D = get_node("Camera")  # Use the exact path that worked before

func _ready() -> void:
	if inventory_ui:
		inventory_ui.visible = false  # Start hidden
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] InventoryUI found. Setting visible = false.")
	elif DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[UIManager] ERROR: InventoryUI not found! Check node path.")

	if camera:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			print("[UIManager] Camera found.")
	elif DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[UIManager] ERROR: Camera not found! Check node path.")

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
				print("[UIManager] Unlocking mouse pointer & disabling camera control.")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Show mouse
			if camera:
				camera.is_inventory_open = true  # Stop camera movement
		else:
			if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
				print("[UIManager] Locking mouse pointer & enabling camera control.")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Lock mouse back in
			if camera:
				camera.is_inventory_open = false  # Resume camera movement
