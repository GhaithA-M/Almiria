extends Control
class_name HealthBar  # ✅ Ensure Godot recognizes this class globally

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

var target = null  # Entity this health bar belongs to

# Attach the health bar to an entity
func set_target(entity) -> void:
	if not entity:
		print("Error: Trying to set HealthBar target to null!")
		return
	
	target = entity

	# ✅ Ensure health component exists before connecting
	if target.has_node("Health"):
		var health_component = target.get_node("Health")
		health_component.health_changed.connect(_update_health)
		_update_health(health_component.current_health)  # Initialize HP display

	# ✅ Ensure the health bar starts visible if required
	_update_visibility()

# Update the health bar when taking damage
func _update_health(new_health: int) -> void:
	if not target:
		return

	progress_bar.value = new_health
	label.text = str(new_health) + " / " + str(target.get_node("Health").max_health)

	_update_visibility()

# ✅ Function to update visibility based on GameSettings
func _update_visibility() -> void:
	match GameSettings.healthbar_mode:
		0:  # Always Off
			visible = false
		1:  # Show on Damage
			visible = true
			await get_tree().create_timer(3.0).timeout  # Hide after 3 sec
			visible = false
		2:  # Always On
			visible = true
