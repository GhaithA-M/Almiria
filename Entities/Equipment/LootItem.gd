extends RigidBody3D
class_name LootItem

# Reference to the dropped item
var item: Item = null

# Debug toggle (global and local)
var LOCAL_DEBUG: bool = false # Enable local debugging

# Node references
@onready var model: MeshInstance3D = $Model
@onready var collision: CollisionShape3D = $Collision
@onready var interact_label: Label3D = $InteractLabel

func _ready():
	gravity_scale = 1.0  # Enable gravity so the loot falls naturally
	_update_interact_label(false)

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

func _on_body_entered(body):
	if body.is_in_group("player"):
		_update_interact_label(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		_update_interact_label(false)

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
