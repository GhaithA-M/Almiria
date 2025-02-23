extends Node  # HealthComponent is a generic node for managing health

class_name HealthComponent  # Assigns a class name for easy reference

# Health variables
@export var max_health: int = 100  # Maximum health the entity can have
@export var current_health: int = 100  # The entity's current health

# Signals for health updates and death
signal health_changed(new_health)  # Emitted when health changes
signal died(entity)  # Emitted when health reaches 0

func take_damage(amount: int):
	if DebugSettings.DEBUG_MODE == 1:
		print("🔥 HealthComponent received damage:", amount)

	current_health -= amount

	if current_health <= 0:
		current_health = 0
		if DebugSettings.DEBUG_MODE == 1:
			print("💀 Entity has died!")
		died.emit()  # REMOVE get_parent() to avoid argument mismatch

	health_changed.emit(current_health)
