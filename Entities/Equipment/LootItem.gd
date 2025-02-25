extends RigidBody3D
class_name LootItem

# Reference to the dropped item
var item: Item = null

# Debug toggle (local)
var LOCAL_DEBUG: bool = false # Enable local debugging

# Node references
@onready var model: MeshInstance3D = get_node_or_null("Model")
@onready var collision: CollisionShape3D = get_node_or_null("Collision")
@onready var interact_label: Label3D = get_node_or_null("InteractLabel")
@onready var interaction_area: Area3D = get_node_or_null("InteractionArea")
@onready var inventory = get_tree().get_first_node_in_group("inventory")

var player_nearby: bool = false  # Tracks if the player is within pickup range

func _ready():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootItem Debug] Initializing loot item")
	
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		if model == null:
			_debug_log("❌ ERROR: Model node not found in LootItem.tscn!")
		if collision == null:
			_debug_log("❌ ERROR: Collision node not found in LootItem.tscn!")
		if interact_label == null:
			_debug_log("❌ ERROR: InteractLabel not found in LootItem.tscn!")
		if interaction_area == null:
			_debug_log("❌ ERROR: InteractionArea not found in LootItem.tscn!")
		if inventory == null:
			_debug_log("❌ ERROR: Inventory system not found in scene!")
	
	# Ensure interaction area connects signals
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_entered)
		interaction_area.body_exited.connect(_on_interaction_area_exited)
	
	_update_interact_label(false)
	set_process_input(true)  # Ensure input processing is enabled
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("✅ LootItem is ready and listening for interactions.")

func set_item(new_item: Item):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootItem Debug] Setting item: ", new_item.name)
	item = new_item
	_update_visual()
	_update_interact_label(true)

func _update_visual():
	if item == null:
		return
	
	var model_path = ""
	match item.name:
		"Basic Boots":
			model_path = "res://Assets/Models/Equipment/Boots/Boots_Basic.tscn"
	
	if model_path != "":
		var model_scene = load(model_path).instantiate()
		add_child(model_scene)
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			_debug_log("Loaded model: %s" % model_path)
	else:
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			_debug_log("No model assigned for item: %s" % item.name)

func _update_interact_label(visible: bool):
	if interact_label:
		interact_label.visible = visible
		if item:
			var key_name = _get_keybind_for_action("pickup_item")  # Get the actual keybind
			interact_label.text = "[" + key_name + "] " + item.name
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Interact label updated: %s" % visible)

func _get_keybind_for_action(action: String) -> String:
	var input_events = InputMap.action_get_events(action)
	if input_events.size() > 0:
		for event in input_events:
			if event is InputEventKey:  # Ensure it's a key event
				return OS.get_keycode_string(event.physical_keycode)  # Use physical_keycode for consistency
	return "?"

func _on_interaction_area_entered(body):
	if body.is_in_group("player"):
		player_nearby = true
		_update_interact_label(true)
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			_debug_log("Player is near loot!")

func _on_interaction_area_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		_update_interact_label(false)
		if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
			_debug_log("Player left loot range.")

func _input(event):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootItem Debug] Processing input event")
	
	if event.is_action_pressed("pickup_item") and DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		_debug_log("Pickup key pressed!")
	
	if player_nearby and event.is_action_pressed("pickup_item"):
		pickup()

func pickup():
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootItem Debug] Attempting to pick up item")
	
	if item:
		if inventory:
			inventory.add_item(item)
			if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
				_debug_log("Picked up item: %s" % item.name)
			queue_free()  # Remove loot after pickup
		else:
			if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
				_debug_log("❌ ERROR: Inventory system not found, cannot pick up item!")

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 and LOCAL_DEBUG:
		print("[LootItem Debug] ", message)
