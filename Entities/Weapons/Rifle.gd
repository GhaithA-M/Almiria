extends Node3D  # Assuming this is attached to FullAutoRifle1

@export var crosshair: Control  # Assign in Inspector

func _ready():
	if crosshair:
		crosshair.visible = false  # Hide by default

func equip():
	if crosshair:
		crosshair.visible = true  # Show crosshair when equipped

func unequip():
	if crosshair:
		crosshair.visible = false  # Hide crosshair when switching weapons
