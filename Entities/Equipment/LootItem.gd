extends RigidBody3D
class_name LootItem

# Reference to the dropped item
var item: Item = null

# Debug toggle (global and local)
var LOCAL_DEBUG: bool = true # Enable local debugging

# Node references
@onready var model: MeshInstance3D = $Model
@onready var collision: CollisionShape3D = $Collision
@onready var interact_label: Label3D = $InteractLabel

var player_nearby: bool = false  # Tracks if the player is within pickup range

func _ready():
	# Ensure all nodes are found
	model = get_node_or_null("Model")
	collision = get_node_or_null("Collision")
	interact_label = get_node_or_null("InteractLabel")
	var interaction_area = get_node_or_null("InteractionArea")
	
	# Debugging to confirm nodes exist
	if model == null:
		_debug_log("❌ ERROR: Model node not found in LootItem.tscn!")
	if collision == null:
		_debug_log("❌ ERROR: Collision node not found in LootItem.tscn!")
	if interact_label == null:
		_debug_log("❌ ERROR: InteractLabel not found in LootItem.tscn!")
	if interaction_area == null:
		_debug_log("❌ ERROR: InteractionArea not found in LootItem.tscn!")
	
	# Set up InteractionArea detection
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_entered)
		interaction_area.body_exited.connect(_on_interaction_area_exited)
	
	# Hide label by default
	if interact_label:
		interact_label.visible = false

	set_process_input(true)  # Enable input detection
	_debug_log("✅ LootItem is ready and listening for interactions.")

func set_item(new_item: Item):
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
		_debug_log("Loaded model: %s" % model_path)
	else:
		_debug_log("No model assigned for item: %s" % item.name)

func _update_interact_label(visible: bool):
	if interact_label:
		interact_label.visible = visible
		if item:
			interact_label.text = "[E] Pick up " + item.name

func _on_interaction_area_entered(body):
	if body.is_in_group("player"):
		player_nearby = true
		_update_interact_label(true)
		_debug_log("Player is near loot!")

func _on_interaction_area_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		_update_interact_label(false)
		_debug_log("Player left loot range.")

func _input(event):
	if event.is_action_pressed("pickup_item"):
		_debug_log("Pickup key pressed!")
	
	if player_nearby and event.is_action_pressed("pickup_item"):
		pickup()

func pickup():
	if item:
		var inventory = get_tree().get_first_node_in_group("inventory")
		if inventory:
			inventory.add_item(item)
			queue_free()  # Remove loot after pickup
			_debug_log("Picked up item: %s" % item.name)

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 or LOCAL_DEBUG:
		print("[LootItem Debug] ", message)
