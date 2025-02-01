extends Control

@onready var healthbar_setting = $SettingsPanel/HealthBarOption

var healthbar_modes = ["Always Off", "Show on Damage", "Always On"]

func _ready():
	healthbar_setting.item_selected.connect(_on_healthbar_setting_selected)
	# Set initial selection
	healthbar_setting.selected = GameSettings.healthbar_mode

func _on_healthbar_setting_selected(index):
	GameSettings.healthbar_mode = index
