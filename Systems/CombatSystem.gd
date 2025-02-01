extends Node

class_name CombatSystem

var CRIT_MULTIPLIER: float = 1.5  # Critical hit bonus multiplier

# Applies damage to a target, factoring in possible crits
func apply_damage(target, base_damage: int, can_crit: bool = true):
	if not target or not target.has_method("take_damage"):
		return
	
	var final_damage = base_damage
	
	# Critical hit calculation
	if can_crit and randf() < 0.15:  # 15% crit chance
		final_damage = int(base_damage * CRIT_MULTIPLIER)
		print("Critical Hit! Damage:", final_damage)

	target.take_damage(final_damage)
