extends Control
class_name HealthBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

# Debug toggle (local)
var LOCAL_DEBUG: bool = false # Set this to true for local debugging

var target = null  # Entity this health bar belongs to

# Attach the health bar to an entity
func set_target(entity) -> void:
	if not entity:
		print("Error: Trying to set HealthBar target to null!")
		return
	
	target = entity
	print("HealthBar target set to:", target)

	# Ensure health component exists before connecting
	if target.has_node("Health"):
		var health_component = target.get_node("Health")
		health_component.health_changed.connect(_update_health)
		print("Connected to health_changed signal of:", health_component)
		_update_health(health_component.current_health)  # Initialize HP display
	else:
		print("Error: Health component not found in target entity")

	# Ensure the health bar starts visible if required
	_update_visibility()

# Update the health bar when taking damage
func _update_health(new_health: int) -> void:
	if not target:
		print("Error: No target set for HealthBar")
		return

	print("Updating health bar to new health:", new_health)
	progress_bar.value = new_health
	label.text = str(new_health) + " / " + str(target.get_node("Health").max_health)

	_update_visibility()

# Function to update visibility based on GameSettings
func _update_visibility() -> void:
	print("Updating visibility based on GameSettings")
	match GameSettings.healthbar_mode:
		0:  # Always Off
			visible = false
			print("HealthBar visibility set to false (Always Off)")
		1:  # Show on Damage
			visible = true
			print("HealthBar visibility set to true (Show on Damage)")
			await get_tree().create_timer(3.0).timeout  # Hide after 3 sec
			visible = false
			print("HealthBar visibility set to false after 3 seconds")
		2:  # Always On
			visible = true
			print("HealthBar visibility set to true (Always On)")
