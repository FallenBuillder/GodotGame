extends Control

@onready var wave_label = $Panel/WaveLabel

func _ready() -> void:
	GameManager.wave_changed.connect(_on_wave_changed)
	WaveManager.level_max_wave_changed.connect(_on_max_wave_changed)
	GameManager.sandbox_mode_set.connect(_update_label)
	_update_label()

func _update_label() -> void:
	if GameManager._sandbox_mode:
		wave_label.text = "Wave: %d" % GameManager.wave
	else:
		wave_label.text = "Wave: %d/%d" % [GameManager.wave, WaveManager.get_level_max_wave()]

func _on_max_wave_changed(_max: int) -> void:
	_update_label()

func _on_wave_changed(_wave: int) -> void:
	_update_label()
