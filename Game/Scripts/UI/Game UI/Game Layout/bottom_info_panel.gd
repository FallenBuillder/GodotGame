extends Panel

@onready var wave_label = $VBoxContainer/WaveLabel
@onready var level_label = $VBoxContainer/LevelLabel
@onready var money_label = $VBoxContainer/MoneyLabel
@onready var health_label = $VBoxContainer/HealthLabel
@onready var xp_bar = $VBoxContainer/XPBar

func _ready() -> void:
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	
	_update_all()

func _update_all() -> void:
	wave_label.text = "Wave: %d / %d" % [GameManager.current_wave, GameManager.total_waves]
	level_label.text = "Level: %s" % GameManager.current_level_name
	money_label.text = "Money: $%d" % GameManager.money
	health_label.text = "Health: %d" % GameManager.health
	
	xp_bar.value = GameManager.xp
	xp_bar.max_value = GameManager.xp_to_next_level

func _on_money_changed(amount: int) -> void:
	money_label.text = "Money: $%d" % amount

func _on_health_changed(amount: int) -> void:
	health_label.text = "Health: %d" % amount

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "Wave: %d / %d" % [wave, GameManager.total_waves]
