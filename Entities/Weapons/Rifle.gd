extends Node3D  # Assuming this is attached to FullAutoRifle1

@export var crosshair: Control  # Assign in Inspector
@export var fire_rate: float = 1.0  # Bullets per second (e.g., 10 means 600 RPM)

@onready var fire_timer = $FireTimer  # Ensure a Timer node named 'FireTimer' is added to this weapon

func _ready():
	if crosshair:
		crosshair.visible = true
	
	fire_timer.wait_time = 1 / fire_rate  # Set fire rate interval
	fire_timer.one_shot = false  # Keep firing while holding shoot
	fire_timer.stop()  # Ensure it starts stopped

func equip():
	if crosshair:
		crosshair.visible = true  # Show crosshair when equipped

func unequip():
	if crosshair:
		crosshair.visible = false  # Hide crosshair when switching weapons

func start_firing():
	if fire_timer.is_stopped():
		fire_timer.start()  # Start firing cycle
		shoot()

func stop_firing():
	fire_timer.stop()  # Stop firing when released

func shoot():
	print("Firing weapon")  # Debug print to confirm firing
	# Placeholder for actual shooting logic (e.g., spawning bullets)
	fire_timer.start()  # Restart timer for continuous firing
