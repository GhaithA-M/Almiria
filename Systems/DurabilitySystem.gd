extends Node

var durability: int = 100  # Starts at full durability (100%)

signal durability_changed(new_value)

func reduce_durability() -> void:
	durability -= 10
	if durability < 80:
		print("Gear effectiveness reduced to " + str(durability) + "%")
	durability_changed.emit(durability)

func repair_all() -> void:
	durability = 100
	durability_changed.emit(durability)
	print("Gear fully repaired!")
