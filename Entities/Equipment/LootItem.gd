extends Node3D
class_name LootItem

# Reference to the dropped item
var item: Item = null

# Debug toggle (global and local)
var LOCAL_DEBUG: bool = false # Enable local debugging

# Node references
@onready var model: MeshInstance3D = $Model
@onready var collision: CollisionShape3D = $Collision

func set_item(new_item: Item):
	item = new_item
	_update_visual()

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

# Debug log function
func _debug_log(message: String):
	if DebugSettings.DEBUG_MODE == 1 or LOCAL_DEBUG:
		print("[LootItem Debug] ", message)
