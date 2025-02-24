extends Node

var inventory_ui: Control  # Declare the variable

func _ready() -> void:
	inventory_ui = get_node_or_null("InventoryUI")  # Use `get_node_or_null` to avoid crashes
	if inventory_ui:
		inventory_ui.visible = false  # Start hidden
		print("[UIManager] InventoryUI found. Setting visible = false.")
	else:
		print("[UIManager] ERROR: InventoryUI not found!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		print("[UIManager] toggle_inventory key pressed.")
		toggle_inventory()

func toggle_inventory() -> void:
	if inventory_ui:
		inventory_ui.visible = !inventory_ui.visible
		print("[UIManager] Toggled InventoryUI. Now visible:", inventory_ui.visible)

		if inventory_ui.visible:
			print("[UIManager] Unlocking mouse pointer.")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Show mouse
		else:
			print("[UIManager] Locking mouse pointer.")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Hide and lock mouse in center
	else:
		print("[UIManager] ERROR: InventoryUI is null!")
