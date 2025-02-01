extends Node

class_name HealthComponent

@export var max_health: int = 100
@export var current_health: int = 100

signal health_changed(new_health)
signal died(entity)

func take_damage(amount: int):
	current_health -= amount
	health_changed.emit(current_health)
	
	if current_health <= 0:
		current_health = 0
		died.emit(get_parent())  # Notify that the entity died.

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)
